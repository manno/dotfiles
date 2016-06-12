# .zlogin: login shell, after zshrc and zprofile(login) and zshenv(always)

## Show ssh agent keys
if [ -x /usr/bin/ssh-add ] && [ "$SSH_AUTH_SOCK" != "" ] && [ -r "$SSH_AUTH_SOCK" ]; then
    /usr/bin/ssh-add -l
fi
