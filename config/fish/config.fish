# use gnu versions of coreutils/findutils
set PATH (brew --prefix coreutils)/libexec/gnubin $PATH
set PATH (brew --prefix findutils)/libexec/gnubin $PATH

set PATH ~/bin $PATH

if test -e ~/.cargo
  set PATH $PATH ~/.cargo/bin
end

if test -e ~/.go
  set -x GOPATH ~/.go
  set PATH $PATH $GOPATH/bin
end

# http://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_char_dirtystate '⚡'

# source versioning
source ~/.asdf/asdf.fish

# add yarn global binaries
set PATH $PATH (yarn global bin)

# alias vim to "mvim -v"
function vim
  command mvim -v $argv
end

# bundle exec
function be
  bundle exec $argv
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

### fasd support

function __fasd_run -e fish_preexec
  command fasd --proc (command fasd --sanitize "$argv" | tr -s ' ' \n) > "/dev/null" 2>&1 &
end

function j
  cd (fasd -d -e 'printf %s' "$argv")
end

### iTerm 2 shell integration

if test -e ~/.iterm2_shell_integration.fish
  source ~/.iterm2_shell_integration.fish
end
status --is-interactive; and . (swiftenv init -|psub)
