# zsh - variables
export WATCH=notme
export LOGCHECK=10
export REPORTTIME=10
export WORDCHARS='*?_.[]~=&;!#$%^(){}<>|-'        # use /- as word seperator
eval `dircolors -b`

# zsh - options
setopt NOhup
setopt extendedglob
setopt NOcheckjobs

# zsh - modules
# mmv *.c.orig orig/*.c
autoload -U zmv
alias mmv='noglob zmv -W'
