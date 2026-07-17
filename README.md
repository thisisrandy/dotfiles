# dotfiles

Various dotfiles, associated scripts and cheatsheets as well as installation scripts and notes

## Ubuntu installation

0. Make sure we're using UEFI (system setup). This will affect how the
   installation of third-party stuff goes, so we need to do it first.

1. Run [install.sh](install.sh) after updating any explicitly-specified
   versions

Note that [zsh-install.sh](zsh-install.sh) &
[vscode-install-extensions.sh](vscode-install-extensions.sh) are run
automatically after Oh-My-Zsh & VS Code are installed, respectively.

Note also that `vim-plug` installs `fzf`, so the latter won't be available
until `nvim` is started for the first time.

Note finally that the [`iriun`](http://iriun.com/) deps installation will
require some interaction when UEFI is configured. I haven't tested this in the
script as of writing.

### Manual Steps

#### Display

After setting up displays, if the login dialog is still on the wrong monitor, run

```
sudo cp ~/.config/monitors.xml ~gdm/.config/monitors.xml
```

#### Turning off network printer discovery

Ubuntu will repeatedly install all network printers on every connect and quite
annoyingly inform the user everytime it has done so. Per [ask
ubuntu](https://askubuntu.com/questions/345083/how-do-i-disable-automatic-remote-printer-installation),
it's possible to turn this off as follows:

```
sudo systemctl stop cups-browsed
sudo systemctl disable cups-browsed
```

This isn't included in [install.sh](install.sh) in case it's desirable behavior.

#### Backup via Timeshift

Timeshift is automatically installed but needs to be configured. Open the
Timeshift application and set up as appropriate. Boot + monthly/weekly/daily
snapshots seem appropriate.

#### GNOME Tweaks

All tweaks are automatically set via `gsettings` during installation. If
desired, additional customization can be performed via the Tweaks interface or
`gsettings`. Here is a convenient one-liner for listing available settings into
a searchable file:

```
gsettings list-schemas | \
   perl -ne 'print; chomp; $schema = $_; for my $key (`gsettings list-keys $schema`) { \
   print "  $key"; for my $rangeItem (`gsettings range $schema $key`) { \
   print "    $rangeItem" } }' > all-gsettings.txt
```

#### Windows dual-boot

If the system is dual boot with windows, run
[this command](https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/)
to fix windows time going awry every time linux is booted:

```
timedatectl set-local-rtc 1 --adjust-system-clock
```

In reverse:

```
timedatectl set-local-rtc 0 --adjust-system-clock
```

#### GNOME extensions

While it's possible to install GNOME extensions programmatically, one has to
match the download url with one's shell version, and the maintenance cost just
isn't worth it for a small list of extensions. I'm only using a few at the
moment, so it's much easier to manually enable it using the GNOME shell
integration chrome plugin. A list of install url(s) follows:

- ~~[OverviewNavigation](https://extensions.gnome.org/extension/1702/overview-navigation/)~~
  *(Not compatible with gnome > 42)*
- [V-Shell](https://extensions.gnome.org/extension/5177/vertical-workspaces/)
- [WSP (Windows Search Provider)](https://extensions.gnome.org/extension/6730/wsp-windows-search-provider/)
- [Dash to Panel](https://extensions.gnome.org/extension/1160/dash-to-panel/).
*(Not currently using in preference to Dash to Dock)* This extension has a config
dump baked into the GUI, so we don't *have* to use `dconf` (see below) but
probably *can*. I exported its settings to
[dash-to-panel.ini](dash-to-panel.ini)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [Hide Cursor](https://extensions.gnome.org/extension/6727/hide-cursor/)
(Wayland replacement for
  [unclutter](https://wiki.archlinux.org/title/Unclutter))
- [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
- [All
Windows](https://extensions.gnome.org/extension/4833/all-windows-saverestore-window-positions/).
I'm using this for the save/restore window positions feature. I
[forked](https://github.com/thisisrandy/all-windows) the extension and exposed
those functions to DBus so I can trigger them from a script (see
[`laptop-monitor-toggle`](laptop-monitor-toggle)). As such, we can't install
from the [the extensions page](https://extensions.gnome.org/) until it's merged
upstream and published. Follow the instructions I wrote down in the [testing
section](https://github.com/thisisrandy/all-windows#testing) of the readme.
- [CHC-E](https://extensions.gnome.org/extension/4167/custom-hot-corners-extended/).
I use this for a few custom shortcuts (prefixed by `Super+Shift`) and nothing
else. Note that its visual effects (none of which I use) seem largely broken.

For extensions with lots of configuration, we can dump it to file using
`dconf`. For example, the Just Perfection config can be exported via `dconf
dump /org/gnome/shell/extensions/just-perfection/ > just-perfection.ini` (see
[`just-perfection.ini`](just-perfection.ini)) and imported via `dconf load
/org/gnome/shell/extensions/just-perfection/ < just-perfection.ini`. Anything
I've dumped at any point lives in this repo.

Note that the [GNOME Shell Integration Chrome
extension](https://chromewebstore.google.com/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep)
is supposedly able to sync these, so this may no longer be a manual step.
(Untested)

#### GPG

Needed for [Github Credential Manager](https://github.com/git-ecosystem/git-credential-manager).
The first `git` action will trigger login.

0. `gpg --full-generate-key`
1. `pass init <gpg-id>`

#### Mounting a partition as /home

[This
answer](https://askubuntu.com/questions/21321/move-home-folder-to-second-drive)
is exactly what's needed for a clear drive. For an encrypted drive, `rsync` per
the answer and then use the `Disks` GUI to set up auto-unlock/mount.

#### navi

This first time running [navi](https://github.com/denisidoro/navi), it will
need to load cheat sheet repos. After installing the default, make sure to also
run `navi add thisisrandy/cheatsheets`.

#### Audio sleep

Ubuntu puts the audio interface to sleep after a few seconds by default. This
results in a loud popping sound in headphones when the interface cycles, and
Bluetooth speakers may go to sleep and not recover without manual cycling.
Fortunately, the fix is easy: Add the following lines to
`/etc/modprobe.d/audio-powersave.conf` (which may not exist):

```
options snd_hda_intel power_save=0
options snd_hda_intel power_save_controller=N
```

This probably drains battery powered output devices faster, but it's worth the
trade-off.

#### Mouse chugging under network load

I was observing some bad mouse chugging when the system was under network load
only (lots of CPU available). This is probably due to the mouse experiencing
interrupt starvation since the network interface is generating tons of packet
interrupts. Amazingly, my first attempt to fix this succeeded. We can modify
`/etc/default/grub` as follows:

```
GRUB_CMDLINE_LINUX_DEFAULT="usbhid.mousepoll=2"
```

If the variable isn't already empty, append to it. Per [the archlinux
wiki](https://wiki.archlinux.org/title/Mouse_polling_rate), this changes the
frequency of mouse polls in ms. Also according to that page, the default is `8`
(rounded down to a power of 2 from 10), so I've 4x'ed the work my CPU has to do
to handle the mouse. I doubt I'll notice any negative impact from this, but
need to remember that it's set just in case. The mouse is noticeably smoother
with this setting on.

## Mounting external RAID member HDDs

The wisdom found collectively in [Ubuntu doesn't "see" external USB Hard
Disk](https://askubuntu.com/questions/318987/ubuntu-doesnt-see-external-usb-hard-disk),
[mount: unknown filesystem type
'linux_raid_member'](https://serverfault.com/questions/383362/mount-unknown-filesystem-type-linux-raid-member),
and [mount unknown filesystem type
'lvm2_member'](https://askubuntu.com/questions/766048/mount-unknown-filesystem-type-lvm2-member)
gets us through to the win. In particular:

- `ls /dev/ | grep sd` before/after to detect whether the HDD is even seen
- `sudo fdisk -l` to find the correct device
- `mount` complains about 'linux_raid_member'
  - `mdadm --assemble --run /dev/md0 <DEVICE>`, assuming `/dev/md0` does not currently exist
- `mount` complains about 'LVM2_member'
  - `sudo apt-get install lvm2` to install the logical volume management tools
  - `vgdisplay` to get volume group UUID
  - `vgrename <VG UUID> new_name` to rename it if there's a name conflict
  - `modprobe dm-mod` to add a device mapping driver
  - `vgchange -ay` to activate
  - `lvscan` to list all logical volumes in all volume groups
  - `mount /dev/new_name/root /(mnt|media/user)/whereever`. May need to create mount location first

## GNOME Boxes

### Getting files out of a VM

1. Launch the client, then click on the client in the Boxes menu and go to
   Preferences -> Devices & Shares -> Folder Shares and add a folder
2. On the client, install `spice-webdavd`, then run `sudo spice-webdavd -p 10000`. "Spice client folder" should now be available from the "Other Locations" menu in Files
3. Sometimes when attempting to open the Spice client folder, it will error
   with `HTTP error: Could not connect: Connection refused`. It seems, per
   [this discussion](https://github.com/utmapp/UTM/discussions/3917), that the
   best way to fix the issue is to manually type `dav://localhost:9843` into
   the `Other Locations -> Connect to Server` textbox

### Migrating a VM to another host

First, get the necessary software using

```
sudo apt-get install qemu-kvm libvirt-daemon-system
```

### Other notes

- Remember to adjust the power settings on new VMs. Boxes doesn't seem able to
  recover when the guest blanks its screen

#### Dump

1. Grab the QCOW disk image(s) in `~/.local/share/gnome-boxes/images`
2. Dump the machine config(s) as follows:

```
sudo apt install qemu-kvm libvirt-daemon-system
virsh -c qemu:///session list --all | awk 'NR>2 { print $2 }' | \
    xargs -I {} sh -c 'virsh -c qemu:///session dumpxml $1 > $1.xml' -- {}
```

#### Load

1. Replace the QCOW image(s) in the same location
2. Run `virsh create CONFIG.xml` for each

## Making use of older GPUs

Ubuntu does a pretty good job of automatically installing
[nouveau](https://nouveau.freedesktop.org/), but it uses the on-board
graphics by default for everything. We can tell any application to use the
Nvidia GPU by specifying `DRI_PRIME=1` in its environment. See [this
answer](https://askubuntu.com/a/941432/1014459) and also [this
documentation](https://nouveau.freedesktop.org/Optimus.html). There's also an
application called
[switcherooctl](https://man.archlinux.org/man/switcherooctl.1.en) that
handles this in a more complete way. Note that `prime-select` from the
`nvidia-prime` functions, but doesn't seem to have any effect.
