set bash vim-support
set -o vi

PS1="\\[\\e]0;\\w\\a\\]\\n\\[\\e[32m\\]\\u@\\h \\[\\e[33m\\]\\w\\[\\e[0m\\]\\n\\\$ "

# NOTE - assumes that 'mount -s --change-cygdrive-prefix /' has been run to

# setup env variables
export PATH=$PATH:/c/Utils

# setup aliases
alias ls='ls --color'
alias grep='grep --color'

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# clear previously set env variable from Windows
RUBYOPT=''
