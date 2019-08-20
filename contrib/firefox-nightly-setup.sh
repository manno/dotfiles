sudo ln -s /opt/firefox/browser/chrome/icons/default/default128.png /usr/share/pixmaps/firefox-nightly.png
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox-nightly
sudo tee -a /usr/share/applications/firefox-nightly.desktop <<EOF
[Desktop Entry]
Name=Firefox Nightly
GenericName=Web Browser
GenericName[de]=Webbrowser
Comment=Browse the Web
Comment[de]=Im Internet surfen
Exec=firefox-nightly --class=FirefoxNightly %u
Icon=firefox-nightly
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=FirefoxNightly
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;
[Desktop Action new-window]
Name=New Window
Name[de]=Neues Fenster
Name[en_GB]=New Window
Name[en_US]=New Window
Exec=firefox-nightly --class=FirefoxNightly --new-window %u

[Desktop Action new-private-window]
Name=New Private Window
Name[de]=Neues privates Fenster
Name[en_GB]=New Private Window
Name[en_US]=New Private Window
Exec=firefox-nightly --class=FirefoxNightly --private-window %u
EOF
