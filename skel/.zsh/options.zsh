# zsh - variables
export WATCH=notme
export LOGCHECK=10
export REPORTTIME=10
export WORDCHARS='*?_.[]~=&;!#$%^(){}<>|-'        # use /- as word seperator
eval `dircolors -b`

# zsh - options
#setopt autocd
setopt NOhup
setopt extendedglob
setopt NOcheckjobs
setopt globcomplete

# zsh - modules
# mmv *.c.orig orig/*.c
autoload -U zmv
alias mmv='noglob zmv -W'


# debian chroot
# FIXME from where???
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    if [ -z "$CPUTYPE" ]; then
        CPUTYPE=`arch`
    fi
fi
