# set bash vim-support
# set -o vi

PS1="\\[\\e]0;\\w\\a\\]\\n\\[\\e[32m\\]\\u@\\h \\[\\e[33m\\]\\w\\[\\e[0m\\]\\n\\\$ "

# NOTE - assumes that 'mount -s --change-cygdrive-prefix /' has been run to

# setup env variables
export PATH=$PATH:/c/Program\ Files/Git/bin:/cygdrive/c/Utils
export GIT_SSH=/c/Program\ Files/PuTTY/plink.exe

# setup aliases
alias ls='ls --color'
alias grep='grep --color'
alias t='todo.sh'
alias less='/c/Program\ Files/Vim/vim72/macros/less.sh'

# bring in completion for todo
source ~/.bash_completion.d/todo_completer.sh
complete -F _todo_sh -o default t

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# clear previously set env variable from Windows
RUBYOPT=''
