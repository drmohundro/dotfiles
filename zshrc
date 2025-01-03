alias ls="eza --icons --group-directories-first"
alias tree="eza --long --header --git --icons --tree --level=4 -a -I=.git --git-ignore"

if [ -d /opt/homebrew/bin ]; then
  PATH=/opt/homebrew/bin:$PATH
  PATH=/opt/homebrew/sbin:$PATH
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
elif [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
  PATH=/usr/local/sbin:$PATH
  . /usr/local/opt/asdf/libexec/asdf.sh
fi

if [ -d /usr/local/share/dotnet ]; then
  PATH=$PATH:/usr/local/share/dotnet
fi

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
