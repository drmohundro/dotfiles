eval "$(oh-my-posh --init --shell zsh --config ~/dev/dotfiles/oh-my-posh-themes/powerlevel10k_modern.omp.json)"
enable_poshtransientprompt

alias ls="exa --icons --group-directories-first"
alias tree="exa --long --header --git --icons --tree --level=4 -a -I=.git --git-ignore"
