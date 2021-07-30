set cursorline           " highlight current line
set guioptions=egt
set guioptions+=c        " c = console dialogs

set lines=44
set columns=126

if has('mac')
  set macligatures
  set guifont=Iosevka:h18
elseif has('unix')
  set guifont=Mono\ 14
elseif has('win32')
  set guifont=Iosevka:h13
  set renderoptions=type:directx,gamma:1.0,contrast:0.2,level:1.0,geom:1,renmode:5,taamode:1
endif

highlight Comment cterm=italic gui=italic
