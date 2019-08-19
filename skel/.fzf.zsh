# Setup fzf
# ---------
if [[ ! "$PATH" == */home/mm/.fzf/bin* ]]; then
  export PATH="$PATH:/home/mm/.fzf/bin"
fi

# Man path
# --------
if [[ ! "$MANPATH" == */home/mm/.fzf/man* && -d "/home/mm/.fzf/man" ]]; then
  export MANPATH="$MANPATH:/home/mm/.fzf/man"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/mm/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/mm/.fzf/shell/key-bindings.zsh"

bindkey "^R" history-incremental-search-backward
bindkey '\er' fzf-history-widget
