# ~/.bashrc: executed by bash(1) for non-login shells.
# executed by .bash_profile too
    
# If running interactively, then:
if [ -n "$PS1" ]; then
    
    # enable color support of ls and also add handy aliases
    if [ `uname` != "FreeBSD" ]; then
      eval `dircolors -b`
    fi

    # aliases
    test -e ~/.alias && . ~/.alias

    # If this is an xterm set the title to user@host:dir
    case $TERM in
    xterm*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
    screen*)
    	echo $TERM
        ;;
    *)
        ;;
    esac

fi

# machine specifix
test -e ~/.env && . ~/.env
test -e ~/.env.localhost && . ~/.env.localhost
test -e /etc/environment && . /etc/environment
export LANG LC_ALL
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
