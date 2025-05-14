# Setup fzf
# ---------
if [[ ! "$PATH" == */$HOME/.fzf/bin* ]]; then
  export PATH="$PATH:/$HOME/.fzf/bin"
fi

# Man path
# --------
if [[ ! "$MANPATH" == */$HOME/.fzf/man* && -d "/home/mm/.fzf/man" ]]; then
  export MANPATH="$MANPATH:/$HOME/.fzf/man"
fi

# Auto-completion + Key bindings
# ------------------------------
if [ -d "$HOME/.fzf/shell" ]; then
    [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null
    source "$HOME/.fzf/shell/key-bindings.zsh"
elif [ -d "$HOMEBREW_PREFIX/opt/fzf/shell" ]; then
    source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" 2> /dev/null
    source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

bindkey "^R" fzf-history-widget
bindkey '\er' history-incremental-search-backward
