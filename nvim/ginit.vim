if has('mac')
  set guifont=JetBrains\ Mono\ Regular\ Nerd\ Font\ Complete:h16
else
  " neovim-qt settings
  if exists(':GuiTabline')
    GuiTabline 0
    GuiFont! JetBrains\ Mono\ NL:h11
  else
    set guifont=JetBrains\ Mono\ NL:h11
  end
end
