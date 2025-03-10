alias ls="eza --icons --group-directories-first"
alias tree="eza --long --header --git --icons --tree --level=4 -a -I=.git --git-ignore"

if [ -d /opt/homebrew/bin ]; then
  PATH=/opt/homebrew/bin:$PATH
  PATH=/opt/homebrew/sbin:$PATH
elif [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
  PATH=/usr/local/sbin:$PATH
fi

if [ -d /usr/local/share/dotnet ]; then
  PATH=$PATH:/usr/local/share/dotnet
fi

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(starship init zsh)"

# Added by Windsurf
export PATH="/Users/david/.codeium/windsurf/bin:$PATH"
