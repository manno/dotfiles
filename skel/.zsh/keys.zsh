# keys

# disable suspend
stty -ixon -ixoff

bindkey -e                              # EMACS
autoload zkbd

load_zkdb_file() {
    found_kbd="0"
    check_kbd() {
        file=$1
        if [ -f "$file" ]; then
            found_kbd="1"
            source "$file"
        fi
    }
        check_kbd ~/.zkbd/$TERM-$VENDOR-$OSTYPE
    if [ "$found_kbd" = "0" ]; then
        echo -e "\e[0;36m"
        echo
        echo not found: ~/.zkbd/$TERM-$VENDOR-$OSTYPE
        zkbd
        cp ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ~/.zkbd/$TERM-$VENDOR-$OSTYPE
    fi
}

# skip cygwin
if [ "$TERM" = "cygwin" ]; then

    load_zkdb_file

elif [ "$OS" = "Windows_NT" ]; then

    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line
    bindkey "^[[3~" delete-char
    bindkey "^[[2~" overwrite-mode
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word

else #  linux

    load_zkdb_file
fi

bindkey "${key[Home]}" beginning-of-line
bindkey "${key[End]}" end-of-line
bindkey "${key[Delete]}" delete-char
bindkey "${key[Insert]}" overwrite-mode
#  Ctrl-left-arrow and Ctrl-right-arrow for word moving
#bindkey '\e[5C' forward-word
#bindkey '\e[5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# all
bindkey ' ' magic-space                 # also do history expansion on space
bindkey '^I' complete-word              # complete on tab, leave expansion to _expand
