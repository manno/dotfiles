# Enable compsys completion.
# hist vars
HISTSIZE=200000
HISTFILE=~/.zsh_history
HISTFILE_OLD=~/.zsh_history.old
if [ $SUDO_USER ] && [ $USER = "root" ]; then
    HISTFILE=~/.zsh_history-sudo
    HISTFILE_OLD=~/.zsh_history-sudo.old
fi
SAVEHIST=200000
# history replacement fc editor
FCEDIT=-

#setopt share_history           # all zsh share history
setopt INC_APPEND_HISTORY       # write after each line
setopt HIST_IGNORE_DUPS         # ignore next line if dupe
setopt EXTENDED_HISTORY         # log date
setopt HIST_EXPIRE_DUPS_FIRST   # throw dupes away if space is limited 
setopt HIST_FIND_NO_DUPS        # no dupes in search
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
