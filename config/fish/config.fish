# use gnu versions of coreutils/findutils
if type -q brew
  set PATH (brew --prefix coreutils)/libexec/gnubin $PATH
  set PATH (brew --prefix findutils)/libexec/gnubin $PATH
end

# local binaries
set PATH ~/bin $PATH

# tell fzf to use rg to list files
set FZF_DEFAULT_COMMAND 'rg --files --hidden --smart-case --glob "!.git/*"'

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
if test -e ~/Library/Python/3.6/bin
  set PATH $PATH ~/Library/Python/3.6/bin
end

# http://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_char_dirtystate '⚡'

# source versioning
if test -e ~/.asdf
  source ~/.asdf/asdf.fish
end

# add yarn global binaries
if begin; type -q yarn; and test -e (yarn global dir)/node_modules/.bin; end
  set PATH $PATH (yarn global dir)/node_modules/.bin
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

### iTerm 2 shell integration

if test -e ~/.iterm2_shell_integration.fish
  source ~/.iterm2_shell_integration.fish
end
