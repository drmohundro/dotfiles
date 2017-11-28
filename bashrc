source ~/.bash/aliases
source ~/.bash/env
source ~/.bash/config

if hash brew 2>/dev/null; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then source $(brew --prefix)/etc/bash_completion; fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
