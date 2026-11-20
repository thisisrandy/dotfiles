#!/usr/bin/env python3
"""Daily Clockify task totals rounded to 0.1 h (6 min) with error carry-over.

Usage: clockify-report.py START END      (inclusive dates, YYYY-MM-DD)

Requires CLOCKIFY_API_KEY in the environment. Output is tab-separated:

    project <TAB> date <TAB> description <TAB> hours

Rounding:
  1. Each (project, description) task's daily total is rounded to the nearest 6 minutes.
  2. The day's rounding error (raw - rounded, summed over tasks) is collected.
  3. That error is added to the day's last task, which is rounded again.
     Whatever error remains is shown in the day's "(rounding error)" row.
  4. Remaining daily errors are summed over the period, added to the last task
     of the last day, and rounded one final time.
  5. The leftover is shown in the final "(period rounding error)" row.

A task is a (project, description) pair. Days are in the user's Clockify time zone, keyed by entry start time. Tasks
within a day are ordered by first start time; the latest-starting one is
"last". Running timers are skipped with a warning.
"""
import json
import os
import sys
import urllib.parse
import urllib.request
from collections import OrderedDict
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

API = "https://api.clockify.me/api/v1"
QUANTUM = 360  # seconds
PAGE_SIZE = 500


def die(msg):
    sys.exit(f"{os.path.basename(sys.argv[0])}: {msg}")


def get(path, params=None):
    url = API + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"X-Api-Key": os.environ["CLOCKIFY_API_KEY"]})
    try:
        with urllib.request.urlopen(req) as resp:
            return json.load(resp), resp.headers
    except urllib.error.HTTPError as e:
        die(f"HTTP {e.code} from {path}: {e.read().decode(errors='replace')[:200]}")


def round_q(seconds):
    """Round to the nearest quantum, halves up."""
    return (seconds + QUANTUM // 2) // QUANTUM * QUANTUM


def fetch_entries(start_date, end_date):
    user, _ = get("/user")
    tz = ZoneInfo(user["settings"]["timeZone"])
    # Inclusive local-date range -> UTC instants.
    lo = datetime.combine(start_date, datetime.min.time(), tz).astimezone(timezone.utc)
    hi = datetime.combine(end_date + timedelta(days=1), datetime.min.time(), tz).astimezone(timezone.utc)
    fmt = "%Y-%m-%dT%H:%M:%SZ"
    entries, page = [], 1
    while True:
        batch, headers = get(
            f"/workspaces/{user['defaultWorkspace']}/user/{user['id']}/time-entries",
            {"start": lo.strftime(fmt), "end": hi.strftime(fmt), "hydrated": "true",
             "page": page, "page-size": PAGE_SIZE},
        )
        entries += batch
        if headers.get("Last-Page", "true").lower() == "true":
            return entries, tz
        page += 1


def parse_utc(s):
    return datetime.strptime(s, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)


def aggregate(entries, tz):
    """-> {date: OrderedDict((project, description) -> raw seconds)}, tasks ordered by first start."""
    days = {}
    for e in sorted(entries, key=lambda e: e["timeInterval"]["start"]):
        iv = e["timeInterval"]
        if not iv.get("end"):
            print(f"warning: skipping running timer {e['id']}", file=sys.stderr)
            continue
        start = parse_utc(iv["start"])
        secs = int((parse_utc(iv["end"]) - start).total_seconds())
        # Keep fields one-line and tab-free.
        project = " ".join(((e.get("project") or {}).get("name") or "(no project)").split())
        desc = " ".join((e.get("description") or "(no description)").split())
        name = (project, desc)
        day = start.astimezone(tz).date()
        tasks = days.setdefault(day, OrderedDict())
        tasks[name] = tasks.get(name, 0) + secs
    return days


def hours(seconds):
    return f"{seconds / 3600:.1f}"


def err_hours(seconds):
    return f"{seconds / 3600:+.3f}"


def main():
    if len(sys.argv) != 3:
        die("usage: clockify-report.py START END   (YYYY-MM-DD, inclusive)")
    if "CLOCKIFY_API_KEY" not in os.environ:
        die("CLOCKIFY_API_KEY is not set")
    try:
        start, end = (datetime.strptime(a, "%Y-%m-%d").date() for a in sys.argv[1:])
    except ValueError:
        die("dates must be YYYY-MM-DD")
    if end < start:
        die("END is before START")

    entries, tz = fetch_entries(start, end)
    days = aggregate(entries, tz)

    # Steps 1-3, per day. rows[date] = [[task, rounded_seconds], ...]
    rows, day_err = {}, {}
    for day in sorted(days):
        tasks = days[day]
        rows[day] = [[name, round_q(raw)] for name, raw in tasks.items()]
        err = sum(tasks.values()) - sum(r for _, r in rows[day])
        rows[day][-1][1] = max(0, round_q(rows[day][-1][1] + err))
        day_err[day] = sum(tasks.values()) - sum(r for _, r in rows[day])

    # Step 4: period error goes onto the final task of the final day.
    period_err = sum(day_err.values())
    if rows:
        last_day = max(rows)
        before = rows[last_day][-1][1]
        rows[last_day][-1][1] = max(0, round_q(before + period_err))
        # The last day's own remaining error changes along with its last task.
        day_err[last_day] -= rows[last_day][-1][1] - before
        period_err = period_err - (rows[last_day][-1][1] - before)

    print("project\tdate\tdescription\thours")
    for day in sorted(rows):
        for (project, desc), secs in rows[day]:
            print(f"{project}\t{day}\t{desc}\t{hours(secs)}")
        print(f"\t{day}\t(rounding error)\t{err_hours(day_err[day])}")
    print(f"\t{start}..{end}\t(period rounding error)\t{err_hours(period_err)}")


if __name__ == "__main__":
    main()
