# install.sh notes

Things that used to be in [install.sh](install.sh) and why they're gone, or
that are worth remembering when touching it. The git history has the code.

## Removed

- **Display drivers** (`ubuntu-drivers autoinstall`, `prime-select nvidia`):
  not needed as of Ubuntu 26.04.
- **zplug:** unacceptably slow to start. May be worth revisiting after an
  upgrade.
- **clangd-9:** an older version of the script installed clangd-9 via
  `update-alternatives`. The reason is lost (jammy shipped clangd 14, so 9 was
  already old), and it might have been legitimate. The script now uses the
  distribution's clangd.
- **The old vim setup** (`init.vim`, `noplug.init.vim`, `ts.init.vim`,
  `coc-settings.json`): replaced by the LazyVim config. The files are still in
  the repo.
- **Docker:** the apt-based install (`docker-ce`, `containerd.io`) stopped
  working on 26.04, where those packages no longer exist in the Ubuntu
  archive. Docker on this machine is installed outside the script. Giving the
  user permission needs `sudo usermod -aG docker $USER` and a new login.
- **HoDoKu:** the jar read as corrupt on 26.04 with the default JRE, so the
  install was disabled. It was a plain download of `hodoku.jar` plus a
  hand-written desktop entry.
- **btop from source:** needed gcc-11, which is gone. btop now comes from apt
  (so it no longer gets `make setuid`) and creates its own desktop entry.
- **git credential manager:** replaced by `gh` for authentication, see the
  `claude_config` step.
- **croissant** (`luarocks install croissant --local`): not available on
  Lua 5.5. `lua -i` is the alternative.

## Worth remembering

- **Lua 5.1 as well as 5.5:** the script builds Lua 5.5 from source, but
  lazy.nvim builds rocks against Lua 5.1 (what Neovim embeds), so the apt
  `lua5.1` and `liblua5.1-0-dev` are needed too. That makes `lua5.1` luarocks'
  preferred interpreter, which is why luarocks is configured with
  `--with-lua=/usr/local`.
- **navi cheatsheets:** `navi repo add` asks questions and then launches navi,
  so the `navi` step clones the default repo and mine and copies the `.cheat`
  files into the cheats path itself (the same layout `repo add` produces).
  Before this, adding the sheets was a manual step in the README.
- **ssh from kitty:** a remote machine needs kitty's terminfo or the prompt and
  cursor are drawn wrongly. That's the `terminfo` step.
- **unclutter on Wayland:** the associated `unclutter-startup` is broken, see
  <https://bugs.launchpad.net/ubuntu/+source/unclutter/+bug/1998720>.
- **Containers:** the `core` profile is what gets tested in docker (24.04 and
  26.04). `desktop` steps (gsettings, snap, flatpak) and `claude_config` can't
  be exercised there.
