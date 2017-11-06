source ~/.bash/aliases
source ~/.bash/env
source ~/.bash/config

if [ -f $(brew --prefix)/etc/bash_completion ]; then source $(brew --prefix)/etc/bash_completion; fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
