alias ls="eza --icons --group-directories-first"
alias tree="eza --long --header --git --icons --tree --level=4 -a -I=.git --git-ignore"

if [ -d /opt/homebrew/bin ]; then
  PATH=/opt/homebrew/bin:$PATH
  PATH=/opt/homebrew/sbin:$PATH
elif [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
  PATH=/usr/local/sbin:$PATH
fi

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

export PATH="/Users/david/bin:$PATH"

# Hermes Agent command
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
