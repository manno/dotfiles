if [ "$(arch)" = "arm64" ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
  alias brew=/opt/homebrew/bin/brew

else
  eval $(/usr/local/bin/brew shellenv)
  alias brew=/usr/local/bin/brew
fi

alias ibrew="arch -x86_64 /usr/local/bin/brew"
alias abrew="arch -arm64 /opt/homebrew/bin/brew"
