# zsh syntax highlighting
plugin=~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $plugin] && source $plugin

# Darwin coreutils
if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
    PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
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
