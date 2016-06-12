# colors
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Add RVM to PATH for scripting
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  path=($HOME/.rvm/bin "$path[@]") 
  rvm_path=$HOME/.rvm
  . "$HOME/.rvm/scripts/rvm" 
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
