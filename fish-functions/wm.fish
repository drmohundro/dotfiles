function __wm_context_handle --description 'Resolve the workmux handle for the current directory'
    type -q workmux; or return 1

    set -l cwd (pwd)
    set -l json (workmux list --json 2>/dev/null)
    test -n "$json"; or return 1

    printf '%s\n' $json | python3 -c 'import json, os, sys
cwd = os.path.realpath(sys.argv[1])
try:
    rows = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)

best = None
best_len = -1
for row in rows:
    if row.get("is_main"):
        continue
    path = row.get("path")
    handle = row.get("handle")
    if not path or not handle:
        continue
    path = os.path.realpath(os.path.expanduser(path))
    if cwd == path or cwd.startswith(path + os.sep):
        if len(path) > best_len:
            best = handle
            best_len = len(path)

if best:
    print(best)
else:
    raise SystemExit(1)
' $cwd 2>/dev/null
end

function __wm_run_workmux --description 'Run a workmux command, starting tmux when needed'
    set -l workmux_command $argv[1]
    set -e argv[1]

    if set -q TMUX
        command workmux $workmux_command $argv
        return $status
    end

    if not type -q tmux
        echo 'wm: tmux not found on PATH' >&2
        return 127
    end

    set -l boot "__workmux_"$workmux_command"_"(date +%s)"_"(random)
    set -l cwd (pwd)
    set -l escaped_args (string escape -- $argv)
    set -l cmd "cd "(string escape -- $cwd)"; workmux "$workmux_command" "(string join ' ' $escaped_args)"; set -l code \$status; if test \$code -ne 0; echo; read -P 'workmux "$workmux_command" failed; press enter to exit '; end; tmux kill-session -t "(string escape -- $boot)" >/dev/null 2>&1; exit \$code"

    command tmux new-session -s $boot -c "$cwd" $cmd
end

function wm --description 'Open or create workmux worktrees with gwh-style attach semantics'
    if not type -q workmux
        echo 'wm: workmux not found on PATH' >&2
        return 127
    end

    set -l workmux_command open
    set -l workmux_args $argv

    if test (count $argv) -eq 0
        set -l handle (__wm_context_handle)
        if test -z "$handle"
            echo 'wm: no current workmux worktree found' >&2
            echo 'usage: wm [worktree-name | open <worktree-name> | new <branch-name>]' >&2
            return 2
        end
        set workmux_args $handle
    else
        switch $argv[1]
            case new add create
                set workmux_command add
                set workmux_args $argv[2..-1]
                if test (count $workmux_args) -eq 0
                    echo 'usage: wm new <branch-name> [workmux add flags...]' >&2
                    return 2
                end
            case open attach
                set workmux_command open
                set workmux_args $argv[2..-1]
                if test (count $workmux_args) -eq 0
                    set -l handle (__wm_context_handle)
                    if test -z "$handle"
                        echo 'wm: no current workmux worktree found' >&2
                        echo 'usage: wm open <worktree-name> [workmux open flags...]' >&2
                        return 2
                    end
                    set workmux_args $handle
                end
            case ls list
                command workmux list $argv[2..-1]
                return $status
            case dashboard dash
                command workmux dashboard $argv[2..-1]
                return $status
            case path
                command workmux path $argv[2..-1]
                return $status
        end
    end

    __wm_run_workmux $workmux_command $workmux_args
end
