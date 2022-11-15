# dotfiles

Various dotfiles, associated scripts and cheatsheets as well as installation scripts and notes

## Ubuntu installation

1. Run [install.sh](install.sh) after updating any explicitly-specified
   versions

Note that [zsh-install.sh](zsh-install.sh) &
[vscode-install-extensions.sh](vscode-install-extensions.sh) are run
automatically after Oh-My-Zsh & VS Code are installed, respectively.

Note also that `vim-plug` installs `fzf`, so the latter won't be available
until `nvim` is started for the first time.

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
to fix windows time going awry everytime linux is booted:

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
isn't worth it for a small list of extensions. In fact, I'm only using one at
the moment, so it's much easier to manually enable it using the GNOME shell
integration chrome plugin. A list of install url(s) follows:

- [windowNavigator](https://extensions.gnome.org/extension/10/windownavigator/)

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
  - `mdmam --assemble --run /dev/md0 <DEVICE>`, assuming `/dev/md0` does not currently exist
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

1. Launch the client, then go to Properties -> Devices & Shares -> Folder Shares and add a folder
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

#### Dump

1. Grab the QCOW disk image(s) in `~/.local/share/gnome-boxes/images`
2. Dump the machine config(s) as follows:

```
sudo apt install qemu-kvm libvirt-daemon-system
virsh list --all | awk 'NR>2 { print $2 }' | \
    xargs -I {} sh -c 'virsh dumpxml $1 > $1.xml' -- {}
```

#### Load

1. Replace the QCOW image(s) in the same location
2. Run `virsh create CONFIG.xml` for each
