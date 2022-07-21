# dotfiles

Various dotfiles, associated scripts and cheatsheets as well as installation scripts and notes

## Ubuntu installation

1. Run [install.sh](install.sh) after updating any explicitly-specified
   versions
2. Run [gnome-stuff.sh](gnome-stuff.sh) and read notes for additional manual
   steps
3. Run [zsh-install.sh](zsh-install.sh) as specified in its USAGE.
4. Run [vscode-install-extensions.sh](vscode-install-extensions.sh)

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

```
sudo apt-get install timeshift
```

Open the Timeshift application and set up as appropriate. Boot + daily
snapshots seem appropriate.

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

## Gnome Boxes

### Getting files out of a VM

1. Launch the client, then go to Properties -> Devices & Shares -> Folder Shares and add a folder
2. On the client, install `spice-webdavd`, then run `sudo spice-webdavd -p 10000`. "Spice client folder" should now be available from the "Other Locations" menu in Files

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
virsh list --all | tail -n +3 | awk '{ print $2 }' | \
    xargs -I {} sh -c 'virsh dumpxml $1 > $1.xml' -- {}
```

#### Load

1. Replace the QCOW image(s) in the same location
2. Run `virsh create CONFIG.xml` for each
