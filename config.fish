set -x MANPAGER 'nvim +Man!'

if test -e /usr/local/bin
  set PATH /usr/local/bin $PATH
end

# use gnu versions of coreutils/findutils
if type -q brew
  # via `brew --prefix FORMULA`... hardcoding for speed, though
  set PATH /usr/local/opt/coreutils/libexec/gnubin $PATH
  set PATH /usr/local/opt/findutils/libexec/gnubin $PATH
  set PATH /usr/local/opt/grep/libexec/gnubin $PATH
end

# local binaries
set PATH ~/bin $PATH

# tell fzf to use rg to list files
if type -q fd
  set -x FZF_DEFAULT_COMMAND 'fd --type f --color=never'
else
  set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --smart-case --glob "!.git/*"'
end

# rust global binaries
if test -e ~/.cargo
  set PATH $PATH ~/.cargo/bin
end

# go global binaries
if test -e ~/.go
  set -x GOPATH ~/.go
  set PATH $PATH $GOPATH/bin
end

# Python 3 binaries
if test -e ~/Library/Python/3.8/bin
  set PATH $PATH ~/Library/Python/3.8/bin
end

# android tooling
if test -e ~/Library/Android/sdk
  set ANDROID_SDK ~/Library/Android/sdk
  set PATH $PATH ~/Library/Android/sdk/platform-tools
end

# http://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_char_dirtystate '⚡'

# source versioning
if test -e ~/.asdf
  source ~/.asdf/asdf.fish
end

# add yarn global binaries (directory comes from `yarn global bin`)
if begin; type -q yarn; and test -e ~/.config/yarn/global/node_modules/.bin; end
  set PATH $PATH ~/.config/yarn/global/node_modules/.bin
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

# alias vim to "mvim -v"
function vim
  command nvim $argv
end

# bundle exec
function be
  bundle exec $argv
end

# smart-cased ripgrep
function rg
  command rg --smart-case $argv
end

if type -q exa
  alias ls "exa --group-directories-first"
end

### Prompt

function fish_prompt
  set_color red
  echo -n "❯"
  set_color yellow
  echo -n "❯"
  set_color green
  echo -n "❯ "
end

function fish_right_prompt
  set_color blue
  echo -n (prompt_pwd)
  set_color green
  echo -n (__fish_git_prompt)
  set_color normal
end

# direnv config
if type -q direnv
  direnv hook fish | source
end

### iTerm 2 shell integration

if test -e ~/.iterm2_shell_integration.fish
  source ~/.iterm2_shell_integration.fish
end

function iterm2_print_user_vars
  iterm2_set_user_var rubyVersion (ruby -v | awk '{ print $2 }')
  iterm2_set_user_var nodeVersion (node -v)
end
