function bloom --description 'Open paths in Bloom'
    set -l count (count $argv)

    if test $count -eq 0
        open -a Bloom .
    else if test $count -eq 1
        open -a Bloom (realpath $argv[1])
    else if test $count -ge 2
        set -l path1 (realpath $argv[1])
        set -l path2 (realpath $argv[2])

        echo "
            tell application \"Bloom\"
                activate
                reopen
                delay 0.3
            end tell

            tell application \"System Events\"
                tell process \"Bloom\"
                    -- Trigger your CMD+OPT+2 shortcut
                    keystroke \"2\" using {command down, option down}
                end tell
            end tell

            tell application \"Bloom\"
                tell front window
                    -- Using 'as «class furl»' or POSIX file to satisfy the (file) type
                    set rootURL of pane 1 to (POSIX file \"$path1\")
                    set rootURL of pane 2 to (POSIX file \"$path2\")
                end tell
            end tell
        " | osascript
    end
end
