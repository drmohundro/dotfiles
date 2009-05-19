# enable bash / vim support
set bash vim-support
set -o vi

# prompt setup
PS1="\\[\\e]0;\\w\\a\\]\\n\\[\\e[32m\\]\\u@\\h \\[\\e[33m\\]\\w\\[\\e[0m\\]\\n\\\$ "

source /etc/profile

# shell options
shopt -s checkwinsize

# NOTE - assumes that 'mount -s --change-cygdrive-prefix /' has been run to

# setup aliases
alias ls='ls --color'
alias grep='grep --color'
alias diff='colordiff'

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# use vim to view git diffs (see http://technotales.wordpress.com/2009/05/17/git-diff-with-vimdiff/)
function git-diff() {
	git diff --no-ext-diff -w "$@" | vim -R -
}

# clear previously set env variable from Windows
RUBYOPT=''
