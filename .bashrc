# set bash vim-support
# set -o vi

# setup env variables
export PATH=$PATH:/cygdrive/c/Program\ Files/Git/bin:/cygdrive/c/Utils

alias t='todo.sh'
alias gitp='ruby /cygdrive/c/DTCDev/Scripts/git-proxy.rb'

# bring in completion for todo
source ~/.bash_completion.d/todo_completer.sh
complete -F _todo_sh -o default t

# enable color support
if [ "$TERM" != "dumb" ]; then
	alias ls='ls --color'
	alias grep='grep --color'
fi

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# clear previously set env variable from Windows
RUBYOPT=''
