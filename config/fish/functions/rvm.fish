function rvm --description='Ruby enVironment Manager'
  # run RVM and capture the resulting environment
  set --local env_file (mktemp -t rvm.fish.XXXXXXXXXX)

  bash -c '[ -e ~/.rvm/scripts/rvm ] && source ~/.rvm/scripts/rvm || source /usr/local/rvm/scripts/rvm; rvm "$@"; status=$?; env > "$0"; exit $status' $env_file $argv

  # grep the rvm_* *PATH RUBY_* GEM_* variables from the captured environment
  # exclude lines with _clr and _debug
  # apply rvm_* *PATH RUBY_* GEM_* variables from the captured environment
  and eval (grep '^rvm\|^[^=]*PATH\|^RUBY_\|^GEM_' $env_file |grep -v _clr |grep -v _debug| sed '/^[^=]*PATH/y/:/ /; s/^/set -xg /; s/=/ /; s/$/ ;/; s/(//; s/)//')

  # clean up
  rm -f $env_file
end

function __check_rvm --on-variable PWD --description 'Setup rvm on directory change'
  status --is-command-substitution; and return

  if test "$rvm_project_rvmrc" != 0
    set -l cwd $PWD
    while true
      if contains $cwd "" $HOME "/"
        if test "$rvm_project_rvmrc_default" = 1
          rvm default 1>/dev/null 2>&1
        end
        break
      else
        if begin ; test -s ".rvmrc" ; or test -s ".ruby-version" ; or test -s ".ruby-gemset" ; or test -s ".versions.conf" ; end
          rvm reload 1> /dev/null 2>&1
          rvm rvmrc load 1>/dev/null 2>&1
          break
        else
          set cwd (dirname "$cwd")
        end
      end
    end

    set -e cwd
  end
end
