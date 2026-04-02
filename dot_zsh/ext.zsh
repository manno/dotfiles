# Darwin coreutils
prefix=${HOMEBREW_PREFIX:-/usr/local}
if [ -d "$prefix/opt/coreutils/libexec/gnubin" ]; then
    PATH="$prefix/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="$prefix/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# Load RVM, path already added in .profile
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  rvm_path=$HOME/.rvm
  . "$HOME/.rvm/scripts/rvm"
fi

# rbenv
if [ -x "$(command -v rbenv)" ]; then
    eval "$(rbenv init - --no-rehash zsh)"
fi

# asdf
if [ -x "$(command -v asdf)" ]; then
  . $(brew --prefix asdf)/asdf.sh
fi

# direnv
if [ -x "$(command -v direnv)" ]; then
    eval "$(direnv hook zsh)"
fi

export PATH
