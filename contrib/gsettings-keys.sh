#!/bin/bash
function dump() {
  gsettings list-recursively org.gnome.desktop.wm.keybindings
  gsettings list-recursively org.gnome.mutter.keybindings
  gsettings list-recursively org.gnome.shell.keybindings
  gsettings list-recursively org.gnome.mutter.wayland.keybindings
}

function org.gnome.shell.keybindings() {
  gsettings set org.gnome.shell.keybindings "$1" "$2"
}

function org.gnome.desktop.wm.keybindings() {
  gsettings set org.gnome.desktop.wm.keybindings "$1" "$2"
}

function org.gnome.mutter.keybindings() {
  gsettings set org.gnome.mutter.keybindings "$1" "$2"
}

dump > keybindings.lst

dconf write /org/gnome/terminal/legacy/keybindings/copy  '"<Super>c"'
dconf write /org/gnome/terminal/legacy/keybindings/paste '"<Super>v"'

org.gnome.shell.keybindings switch-to-application-1 []
org.gnome.shell.keybindings switch-to-application-2 []
org.gnome.shell.keybindings switch-to-application-3 []
org.gnome.shell.keybindings switch-to-application-4 []
org.gnome.shell.keybindings switch-to-application-5 []
org.gnome.shell.keybindings switch-to-application-6 []
org.gnome.shell.keybindings switch-to-application-7 []
org.gnome.shell.keybindings switch-to-application-8 []
org.gnome.shell.keybindings switch-to-application-9 []
org.gnome.shell.keybindings toggle-message-tray []
org.gnome.shell.keybindings toggle-application-view []

org.gnome.desktop.wm.keybindings maximize []
org.gnome.desktop.wm.keybindings minimize []
org.gnome.desktop.wm.keybindings unmaximize []

org.gnome.mutter.keybindings toggle-tiled-right "['<Alt><Super>Right']"
org.gnome.mutter.keybindings toggle-tiled-left "['<Alt><Super>Left']"

#dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape', 'compose:ralt']"
