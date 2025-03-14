source ~/.bash/env
source ~/.bash/aliases
source ~/.bash/config

if hash brew 2>/dev/null; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then source $(brew --prefix)/etc/bash_completion; fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
