#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_PATH="/org/gnome/shell/extensions"

usage() {
    echo "Usage: $0 [--load | --dump]"
    echo "  --load  Load all extension configs from .ini files into dconf"
    echo "  --dump  Dump all extension configs from dconf into .ini files"
    exit 1
}

[[ $# -ne 1 ]] && usage

case "$1" in
    --load)
        for ini in "$SCRIPT_DIR"/*.ini; do
            name="$(basename "$ini" .ini)"
            echo "Loading $BASE_PATH/$name/"
            dconf load "$BASE_PATH/$name/" < "$ini"
        done
        ;;
    --dump)
        for ini in "$SCRIPT_DIR"/*.ini; do
            name="$(basename "$ini" .ini)"
            echo "Dumping $BASE_PATH/$name/"
            dconf dump "$BASE_PATH/$name/" > "$ini"
        done
        ;;
    *)
        usage
        ;;
esac
