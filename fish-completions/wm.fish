function __fish_wm_workmux_handles --description 'List workmux worktree handles'
    # Keep completion fast: avoid `workmux list --json` here because it also
    # checks mux/agent state. For completion, git's local worktree list is enough.
    set -l rows (command git worktree list --porcelain 2>/dev/null)
    test (count $rows) -gt 0; or return

    set -l worktree
    set -l branch
    set -l seen_main 0

    for row in $rows
        if string match -q 'worktree *' -- $row
            if test -n "$worktree"
                if test $seen_main -eq 1
                    set -l handle (basename $worktree)
                    set -l desc (string replace -r '^refs/heads/' '' -- $branch)
                    printf '%s\t%s — %s\n' $handle $desc $worktree
                else
                    set seen_main 1
                end
            end

            set worktree (string replace -r '^worktree ' '' -- $row)
            set branch ''
        else if string match -q 'branch *' -- $row
            set branch (string replace -r '^branch ' '' -- $row)
        end
    end

    if test -n "$worktree"; and test $seen_main -eq 1
        set -l handle (basename $worktree)
        set -l desc (string replace -r '^refs/heads/' '' -- $branch)
        printf '%s\t%s — %s\n' $handle $desc $worktree
    end
end

function __fish_wm_git_branches --description 'List git branches for wm new completions'
    if functions -q __fish_git_branches
        __fish_git_branches
        return
    end

    command git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null | string replace -r '^origin/HEAD$' ''
end

function __fish_wm_uses_add --description 'True when completing wm new/add/create'
    set -l tokens (commandline -opc)
    test (count $tokens) -ge 2; and contains -- $tokens[2] new add create
end

function __fish_wm_uses_open --description 'True when completing wm open/default attach flow'
    not __fish_wm_uses_add
end

complete -c wm -f -n 'not __fish_seen_subcommand_from new add create open attach ls list dashboard dash path' -a 'new' -d 'Create and open a workmux worktree'
complete -c wm -f -n 'not __fish_seen_subcommand_from new add create open attach ls list dashboard dash path' -a 'open' -d 'Open an existing workmux worktree'
complete -c wm -f -n 'not __fish_seen_subcommand_from new add create open attach ls list dashboard dash path' -a 'list' -d 'List workmux worktrees'
complete -c wm -f -n 'not __fish_seen_subcommand_from new add create open attach ls list dashboard dash path' -a 'dashboard' -d 'Open workmux dashboard'
complete -c wm -f -n 'not __fish_seen_subcommand_from new add create open attach ls list dashboard dash path' -a 'path' -d 'Print worktree path'

complete -c wm -f -n '__fish_wm_uses_open' -a '(__fish_wm_workmux_handles)' -d 'Workmux worktree'
complete -c wm -f -n '__fish_wm_uses_add' -a '(__fish_wm_git_branches)' -d 'Git branch'

# workmux open flags, used by `wm <handle>` and `wm open <handle>`.
complete -c wm -n '__fish_wm_uses_open' -s h -l help -d 'Show help'
complete -c wm -n '__fish_wm_uses_open' -s n -l new -d 'Force opening in a new window'
complete -c wm -n '__fish_wm_uses_open' -l mode -x -a 'window session' -d 'Override multiplexer mode'
complete -c wm -n '__fish_wm_uses_open' -s s -l session -d 'Open in session mode'
complete -c wm -n '__fish_wm_uses_open' -l target-name -x -d 'Override workmux-managed tmux target name'
complete -c wm -n '__fish_wm_uses_open' -l parent-session -x -d 'Create window inside named tmux session'
complete -c wm -n '__fish_wm_uses_open' -l config -r -F -d 'Use alternate workmux config'
complete -c wm -n '__fish_wm_uses_open' -l run-hooks -d 'Re-run post_create hooks'
complete -c wm -n '__fish_wm_uses_open' -l force-files -d 'Re-apply file copy/symlink operations'
complete -c wm -n '__fish_wm_uses_open' -s p -l prompt -x -d 'Inline prompt for AI agent panes'
complete -c wm -n '__fish_wm_uses_open' -s P -l prompt-file -r -F -d 'Prompt file for AI agent panes'
complete -c wm -n '__fish_wm_uses_open' -s c -l continue -d "Resume agent's most recent conversation"
complete -c wm -n '__fish_wm_uses_open' -s e -l prompt-editor -d 'Open editor to write prompt'
complete -c wm -n '__fish_wm_uses_open' -l prompt-file-only -d 'Write prompt file without injecting it into agent commands'

# workmux add flags, used by `wm new ...`.
complete -c wm -n '__fish_wm_uses_add' -s h -l help -d 'Show help'
complete -c wm -n '__fish_wm_uses_add' -l base -x -a '(__fish_wm_git_branches)' -d 'Base branch, commit, or tag'
complete -c wm -n '__fish_wm_uses_add' -l pr -x -d 'Checkout GitHub pull request number'
complete -c wm -n '__fish_wm_uses_add' -s A -l auto-name -d 'Generate branch name from prompt using LLM'
complete -c wm -n '__fish_wm_uses_add' -l name -x -d 'Override worktree directory and default target name'
complete -c wm -n '__fish_wm_uses_add' -l target-name -x -d 'Override workmux-managed tmux target name'
complete -c wm -n '__fish_wm_uses_add' -l parent-session -x -d 'Create window inside named tmux session'
complete -c wm -n '__fish_wm_uses_add' -s b -l background -d 'Create tmux target in background'
complete -c wm -n '__fish_wm_uses_add' -s w -l with-changes -d 'Move uncommitted changes to new worktree'
complete -c wm -n '__fish_wm_uses_add' -l patch -d 'Interactively select changes to move'
complete -c wm -n '__fish_wm_uses_add' -s u -l include-untracked -d 'Also move untracked files'
complete -c wm -n '__fish_wm_uses_add' -s p -l prompt -x -d 'Inline prompt for AI agent panes'
complete -c wm -n '__fish_wm_uses_add' -s P -l prompt-file -r -F -d 'Prompt file for AI agent panes'
complete -c wm -n '__fish_wm_uses_add' -s e -l prompt-editor -d 'Open editor to write prompt'
complete -c wm -n '__fish_wm_uses_add' -l prompt-file-only -d 'Write prompt file without injecting it into agent commands'
complete -c wm -n '__fish_wm_uses_add' -s l -l layout -x -d 'Use named pane layout from config'
complete -c wm -n '__fish_wm_uses_add' -s a -l agent -x -d 'Agent to use for the worktree'
complete -c wm -n '__fish_wm_uses_add' -s W -l wait -d 'Block until created tmux target is closed'
complete -c wm -n '__fish_wm_uses_add' -s o -l open-if-exists -d 'Open existing worktree instead of failing'
complete -c wm -n '__fish_wm_uses_add' -l mode -x -a 'window session' -d 'Override multiplexer mode'
complete -c wm -n '__fish_wm_uses_add' -s s -l session -d 'Create in session mode'
complete -c wm -n '__fish_wm_uses_add' -l config -r -F -d 'Use alternate workmux config'
complete -c wm -n '__fish_wm_uses_add' -l fork -x -d 'Fork Claude conversation context'
complete -c wm -n '__fish_wm_uses_add' -s H -l no-hooks -d 'Skip post_create hooks'
complete -c wm -n '__fish_wm_uses_add' -s F -l no-file-ops -d 'Skip file copy/symlink operations'
complete -c wm -n '__fish_wm_uses_add' -s C -l no-pane-cmds -d 'Skip executing pane commands'
complete -c wm -n '__fish_wm_uses_add' -s n -l count -x -d 'Create multiple worktrees'
complete -c wm -n '__fish_wm_uses_add' -l foreach -x -d 'Create worktrees from variable matrix'
complete -c wm -n '__fish_wm_uses_add' -l branch-template -x -d 'Template for generated branch names'
complete -c wm -n '__fish_wm_uses_add' -l max-concurrent -x -d 'Limit concurrent generated worktrees'
