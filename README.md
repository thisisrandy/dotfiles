# dotfiles

Various dotfiles, associated scripts and cheatsheets

## Ubuntu installation

1. Run [install.sh](install.sh) after updating any explicitly-specified
   versions
2. Run [gnome-stuff.sh](gnome-stuff.sh) and read notes for additional manual
   steps
3. Run [zsh-install.sh](zsh-install.sh) as specified in its USAGE.
4. Once VSCode is installed, run [vscode-install-extensions.sh](vscode-install-extensions.sh)

### Manual Steps

#### Display

After setting up displays, if the login dialog is still on the wrong monitor, run

```
sudo cp ~/.config/monitors.xml ~gdm/.config/monitors.xml
```
