#!/bin/sh

[ -x "$(command -v update-alternatives)" ] || exit 0

[ -e /usr/local/bin/nvim ] && sudo ln -s /usr/local/bin/nvim /usr/bin/nvim
[ -x "$(command -v nvim)" ] || exit 0

sudo update-alternatives --install "/usr/bin/vi" "vi" "/usr/bin/nvim" 9000
sudo update-alternatives --install "/usr/bin/vim" "vim" "/usr/bin/nvim" 9000
sudo update-alternatives --set vi "/usr/bin/nvim"
sudo update-alternatives --set vim "/usr/bin/nvim"
