cd ~/Downloads
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cp -r ~/.local/share/fonts ~/.fonts  #I'd rather have it here, your choice

cat >> ~/.Xresources <<EOF
URxvt.font: xft:Roboto Mono Medium:pixelsize=12:antialias=true:hinting=true,
 xft:Roboto Mono Medium for Powerline:pixelsize=12:antialias=true:hinting=true
EOF

sudo fc-cache -f -v  
