if [ -f /usr/bin/gnome-keyring-daemon ] && [ -n "$PS1" ] && [ -n "$DISPLAY" ] && [ -z "$SSH_CONNECTION" ]; then
    # Start GNOME Keyring
    eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
    # You probably need to do this too:
    export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
fi
