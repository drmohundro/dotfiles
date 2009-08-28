#-------------------------------------------------

# pick from directories visited in this session and cd into it
function tb() {
  pick_with_vim "dirs -l -p" "cd"
}


#-------------------------------------------------

# pick from a list of directories (recursive) and cd into it
function c() {
  pick_with_vim "ftd" "cd"
}

