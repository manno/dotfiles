# ~/.bash_profile: executed by bash(1) for login shells.

umask 022

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# BASH Prompt Settings
#export PS1='\u@\h:\w\$ '
export PS1="\u\[\033[0;31m\]@\[\033[0;0m\]\h:\w\[\033[0;31m\]\$ \[\033[0;0m\]"

# BASH Settings
export GLOBIGNORE="*(*/).svn:*(*/).cvs"     # exclude svn/cvs dirs from glob
export FIGNORE="/.svn:/.cvs"                # exclude svn/cvs dirs from completion
set -b                                      # report job status immediately
shopt -s cdspell                            # correct minor spelling errors on cd

# HISTORY Settings
export HISTCONTROL=ignoredups
export HISTIGNORE="$HISTIGNORE:ls:l:ll:cd"
export HISTSIZE=950000                      # number of commands to remember in history
export HISTFILESIZE=950000                  # number of lines in history file 
shopt -s histreedit                         # re-edit a failed history substitution

#annoyed of beeping console?
#setterm -blength 0

# read my locale file
if [ -f "$HOME/.zsh/locale" ] ; then
  . "$HOME/.zsh/locale"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# add super user paths
export PATH=/sbin:/usr/sbin:/usr/local/sbin:"${PATH}"
