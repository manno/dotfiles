# zsh syntax highlighting
plugin=~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $plugin] && source $plugin

# Darwin coreutils
prefix=${HOMEBREW_PREFIX:-/usr/local}
if [ -d "$prefix/opt/coreutils/libexec/gnubin" ]; then
    PATH="$prefix/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="$prefix/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# add super user paths
#path=(/sbin /usr/sbin /usr/local/sbin $path)

# Load RVM, path already added in .profile
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  rvm_path=$HOME/.rvm
  . "$HOME/.rvm/scripts/rvm" 
fi

# Add GOPATH/bin to PATH
if [[ -d "$HOME/go/bin" ]]; then
    path=($HOME/go/bin "$path[@]")
fi

# direnv
if [ -x "$(command -v direnv)" ]; then
    eval "$(direnv hook zsh)"
fi

export PATH
