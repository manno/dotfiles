# keys

# disable # glob
 disable -p '#'

# disable suspend
stty -ixon -ixoff

# emacs bindings
bindkey -e

# Modern standard key bindings (works with most terminals)
bindkey "^[[H" beginning-of-line      # Home
bindkey "^[[F" end-of-line            # End
bindkey "^[[3~" delete-char           # Delete
bindkey "^[[2~" overwrite-mode        # Insert

# xterm variants
bindkey "^[OH" beginning-of-line  # Home (xterm)
bindkey "^[OF" end-of-line        # End (xterm)

# Optional: Use zkbd for specialized terminals (set ZSH_USE_ZKBD=1)
if [[ -n $ZSH_USE_ZKBD ]]; then
    typeset -g ZKBD_CONFIG

    check_kbd() {
        file=$1
        if [ -f "$file" ]; then
            ZKBD_CONFIG="$file"
            source "$file"
        fi
    }

    check_kbd ~/.zkbd/"$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}"
    [[ -z $ZKBD_CONFIG ]] && check_kbd ~/.zkbd/"$TERM-$VENDOR-$OSTYPE"
    [[ -z $ZKBD_CONFIG ]] && check_kbd ~/.zkbd/"$TERM-$VENDOR"
    [[ -z $ZKBD_CONFIG ]] && check_kbd ~/.zkbd/"$TERM"

    if [ "$ZKBD_CONFIG" = "" ]; then
        echo -e "\e[0;32m"
        echo
        echo "not found: ~/.zkbd/$TERM-$VENDOR-$OSTYPE"
        echo "generate: autoload zkbd; zkbd; cp ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ~/.zkbd/$TERM-$VENDOR-$OSTYPE"
        echo -e "\e[0;30m"

    else
        bindkey "${key[Home]}" beginning-of-line
        bindkey "${key[End]}" end-of-line
        bindkey "${key[Delete]}" delete-char
        bindkey "${key[Insert]}" overwrite-mode
    fi
fi

# Ctrl-left-arrow and Ctrl-right-arrow for word moving
#bindkey '\e[5C' forward-word
#bindkey '\e[5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# all
bindkey ' ' magic-space                 # also do history expansion on space
bindkey '^I' complete-word              # complete on tab, leave expansion to _expand

# edit command line in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
