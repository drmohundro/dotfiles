complete -c ptop -f
complete -c ptop -s c -l cpu -d 'Show top processes by CPU'
complete -c ptop -s m -l mem -d 'Show top processes by memory'
complete -c ptop -s n -l top -x -a '5 10 15 20 25' -d 'Number of processes to show'
complete -c ptop -s h -l help -d 'Show help'
