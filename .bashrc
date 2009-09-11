###########################################################
# GENERAL
###########################################################

set bash vim-support
set -o vi

PS1="\\[\\e]0;\\w\\a\\]\\n\\[\\e[32m\\]\\u@\\h \\[\\e[33m\\]\\w\\[\\e[0m\\]\\n\\\$ "

source /etc/profile

shopt -s checkwinsize

# NOTE - assumes that 'mount -s --change-cygdrive-prefix /' has been run to
export SHELL=bash
export FIND_OPTIONS="-name .git -prune -o -name .hg -prune -o -name *.swp -prune -o -name _ReSharper.* -prune -o"

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

###########################################################
# ALIASES
###########################################################

for file in $HOME/.bash/aliases/*.sh; do
	source $file
done

###########################################################
# FUNCTIONS
###########################################################

for file in $HOME/.bash/lib/*.sh; do
	source $file
done
