set -gx MANPAGER 'nvim +Man!'
set -gx EDITOR nvim

# avoid the delay of (brew --prefix)
if test -e /usr/local/bin
  set BREW_PREFIX = /usr/local
  set -gx PATH $BREW_PREFIX/bin $PATH
  set -gx PATH $BREW_PREFIX/sbin $PATH
end

# m1 homebrew installs here instead
if test -e /opt/homebrew/bin
  set BREW_PREFIX = /opt/homebrew
  set -gx PATH $BREW_PREFIX/bin $PATH
  set -gx PATH $BREW_PREFIX/sbin $PATH
end

if test -e ~/.dotnet/tools
  set -gx PATH $PATH ~/.dotnet/tools
end

if test -e /usr/local/share/dotnet
  set -gx PATH $PATH /usr/local/share/dotnet
end

set -gx PATH $PATH /usr/local/opt/postgresql@15/bin

# use gnu versions of coreutils/findutils
if type -q brew
  # via `brew --prefix FORMULA`... hardcoding for speed, though
  set -gx PATH $BREW_PREFIX/opt/coreutils/libexec/gnubin $PATH
  set -gx PATH $BREW_PREFIX/opt/findutils/libexec/gnubin $PATH
  set -gx PATH $BREW_PREFIX/opt/grep/libexec/gnubin $PATH
end

# local binaries
set PATH ~/bin $PATH

fzf --fish | source

# tell fzf to use rg to list files
if type -q fd
  set -gx FZF_DEFAULT_COMMAND 'fd --type f --color=never'
else
  set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --smart-case --glob "!.git/*"'
end

# rust global binaries
if test -e ~/.cargo
  set -gx PATH $PATH ~/.cargo/bin
end

# krew for kubectl
if test -e ~/.krew
  set -gx PATH $PATH ~/.krew/bin
end

# go global binaries
if test -e ~/go
  set -x GOPATH ~/go
  set -x GOROOT "/usr/local/opt/go/libexec"
  set -gx PATH $PATH $GOPATH/bin
  set -gx PATH $PATH $GOROOT/bin
end

if type -q uv
  uv generate-shell-completion fish | source
end

# android tooling
if test -e ~/Library/Android/sdk
  set -gx ANDROID_SDK ~/Library/Android/sdk
  set -gx PATH $PATH ~/Library/Android/sdk/platform-tools
end

# source versioning
if begin; type -q brew; and test -d /usr/local/opt/asdf/; end
  source /usr/local/opt/asdf/libexec/asdf.fish
else if begin; type -q brew; and test -d /opt/homebrew/opt/asdf/; end
  source /opt/homebrew/opt/asdf/libexec/asdf.fish
else if test -e ~/.asdf
  source ~/.asdf/asdf.fish
end

# add yarn global binaries (directory comes from `yarn global bin`)
if begin; type -q yarn; and test -e ~/.config/yarn/global/node_modules/.bin; end
  set -gx PATH $PATH ~/.config/yarn/global/node_modules/.bin
end

# see https://junegunn.kr/2015/03/browsing-git-commits-with-fzf
function fshow
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "." |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
end

alias vim="nvim"
alias rg="rg --smart-case"
alias http="xh"

# default to showing the time for the history entries
function history
  builtin history --show-time='%F %T ' $argv | less -F
end

if type -q eza
  alias tree "eza --long --header --git --icons --tree --level=4 -a -I=.git --git-ignore"
  alias ls "eza --icons --group-directories-first"
end

# prefer starship, fallback to oh-my-posh, then default
if type -q starship
  starship init fish | source
else if type -q oh-my-posh
  oh-my-posh --init --shell fish --config ~/dev/dotfiles/oh-my-posh-themes/mo-fish.omp.json | source
else
  echo "oh-my-posh wasn't found, using default prompt"
end

# direnv config
if type -q direnv
  direnv hook fish | source
end

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

# zoxide (like autojump/fasd/z)
zoxide init fish --cmd j --hook pwd | source

### iTerm 2 shell integration

if test -e ~/.iterm2_shell_integration.fish
  source ~/.iterm2_shell_integration.fish
end

function iterm2_print_user_vars
  iterm2_set_user_var rubyVersion (ruby -v | awk '{ print $2 }')
  iterm2_set_user_var nodeVersion (node -v)
end

if status --is-interactive
  atuin init fish --disable-up-arrow | source
end
