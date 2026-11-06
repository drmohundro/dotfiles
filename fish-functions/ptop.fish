function __ptop_table --argument-names title sort_column limit --description 'Print the processes using the most of a resource'
    echo $title
    ps -axo pid=,pcpu=,rss=,comm= | sort -k$sort_column,$sort_column -rn | head -n $limit | awk '
        BEGIN { printf "%7s %6s %9s  %s\n", "PID", "%CPU", "MEM", "COMMAND" }
        {
            command = $0
            sub(/^ *[0-9]+ +[0-9.]+ +[0-9]+ +/, "", command)
            sub(/.*\//, "", command)
            mb = $3 / 1024
            mem = mb >= 1024 ? sprintf("%.1f GB", mb / 1024) : sprintf("%.0f MB", mb)
            printf "%7d %6.1f %9s  %s\n", $1, $2, mem, command
        }'
end

function ptop --description 'Show the top processes by CPU and/or memory'
    argparse h/help c/cpu m/mem 'n/top=!_validate_int --min 1' -- $argv; or return

    if set -q _flag_help
        echo 'Usage: ptop [-c|--cpu] [-m|--mem] [-n|--top N]'
        echo
        echo 'Shows both CPU and memory unless one is selected. N defaults to 5.'
        return
    end

    if test (count $argv) -gt 0
        echo "ptop: unexpected argument: $argv[1]" >&2
        return 2
    end

    set -l limit 5
    set -q _flag_top; and set limit $_flag_top

    set -l show_cpu (set -q _flag_cpu; or not set -q _flag_mem; and echo 1)
    set -l show_mem (set -q _flag_mem; or not set -q _flag_cpu; and echo 1)

    if test -n "$show_cpu"
        __ptop_table 'Top by CPU' 2 $limit
    end
    if test -n "$show_cpu" -a -n "$show_mem"
        echo
    end
    if test -n "$show_mem"
        __ptop_table 'Top by memory' 3 $limit
    end
end
