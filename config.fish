set -gx MANPAGER 'nvim +Man!'
set -gx EDITOR nvim

# avoid the delay of (brew --prefix)
if test -e /usr/local/bin
    set BREW_PREFIX = /usr/local
    fish_add_path --prepend $BREW_PREFIX/bin
    fish_add_path --prepend $BREW_PREFIX/sbin
end

# m1 homebrew installs here instead
if test -e /opt/homebrew/bin
    set BREW_PREFIX = /opt/homebrew
    fish_add_path --prepend $BREW_PREFIX/bin
    fish_add_path --prepend $BREW_PREFIX/sbin
end

fish_add_path ~/.dotnet/tools
fish_add_path /usr/local/share/dotnet
fish_add_path ~/.local/bin
fish_add_path /usr/local/opt/postgresql@15/bin
fish_add_path /Applications/Obsidian.app/Contents/MacOS

# use gnu versions of coreutils/findutils
if type -q brew
    # via `brew --prefix FORMULA`... hardcoding for speed, though

    fish_add_path --prepend $BREW_PREFIX/opt/coreutils/libexec/gnubin
    fish_add_path --prepend $BREW_PREFIX/opt/findutils/libexec/gnubin
    fish_add_path --prepend $BREW_PREFIX/opt/grep/libexec/gnubin
end

fish_add_path ~/dev/flutter/bin
fish_add_path --prepend ~/bin

# rust global binaries
fish_add_path ~/.cargo/bin

# go global binaries
if test -e ~/go
    set -x GOPATH ~/go
    set -x GOROOT /usr/local/opt/go/libexec

    fish_add_path $GOPATH/bin
    fish_add_path $GOROOT/bin
end

fzf --fish | source

# tell fzf to use rg to list files
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --color=never'
else
    set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --smart-case --glob "!.git/*"'
end

if type -q uv
    uv generate-shell-completion fish | source
end

if type -q mani
    mani completion fish | source
end

# android tooling
if test -e ~/Library/Android/sdk
    set -gx ANDROID_SDK ~/Library/Android/sdk

    fish_add_path ~/Library/Android/sdk/platform-tools
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

if type -q jj
    jj util completion fish | source
end

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

# zoxide (like autojump/fasd/z)
zoxide init fish --cmd j --hook pwd | source

eval "$(fnox activate fish)"

if status --is-interactive
    atuin init fish --disable-up-arrow | source
end
