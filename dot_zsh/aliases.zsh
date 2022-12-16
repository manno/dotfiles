# Aliases

# filters
alias -g G='|grep -i'
alias -g XXD='|xxd'
alias -g L='|less'

# globs
alias -g glob_recent='**/*(om[1])'
alias -g FILES='**/*(.)'

# redirects
alias -g V='2>&1 > /tmp/stdin.$$; vi /tmp/stdin.$$'

# time
alias -g TODAY=$(date +%Y%m%d)
#alias -g NOW=$(date +%T)

# dir shortcuts
alias -g ...='../..'
alias -g ....='../../..'

# load bash aliases
[[ -f ~/.alias ]] && . ~/.alias

# overwrite bash aliases for zsh
#alias r=fc
alias h='less $HISTFILE'
alias h1='less $HISTFILE_OLD'
alias -g hist0='perl -a -F: -MTime::Local -ne "\$F[1]=\" \".localtime(\$F[1]); print join(\":\", @F);" $HISTFILE | less'
alias -g hist1='perl -a -F: -MTime::Local -ne "\$F[1]=\" \".localtime(\$F[1]); print join(\":\", @F);" $HISTFILE_OLD | less'
alias reload='source $HOME/.zshrc'
alias -g vi!='vi `fc -n | xargs`'

# git
#
# git grep text nogo
alias -g nogo='":!*_test.go" ":!*fake*.go" ":!vendor/*"'
# ls *.go~_test.go
