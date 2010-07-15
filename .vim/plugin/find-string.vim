" File:         find-string.vim
" Author:       David Mohundro <drmohundro@gmail.com>
" URL:          ...
"
" This script is just a provider for the PowerShell find-string
" script, that is itself an homage to the Ack utility. In fact,
" this script is based *heavily* on the ack.vim script from
" http://github.com/mileszs/ack.vim/. So, thanks to all of the
" aforementioned projects.

function! s:FindString(cmd, args)
  redraw
  echo "Searching ..."

  let findstringprg="find-string-wrapper"
  let findstringformat="%f:%l:%m"

  let shell_bak=&shell
  let shellcmdflag_bak=&shellcmdflag
  let shellpipe_bak=&shellpipe
  let shellredir_bak=&shellredir
  let shellxquote_bak=&shellxquote

  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat
  try
    let &shell="powershell.exe -noprofile"
    let &shellcmdflag="-c"
    let &shellpipe="| out-file -encoding ASCII -force -width 120 %s 2>&1"
    let &shellredir="| out-file -encoding ASCII -force -width 120 %s 2>&1"
    let &shellxquote="\""

    let &grepprg=findstringprg
    let &grepformat=findstringformat
    silent execute a:cmd . " " . a:args
  finally
    let &shell=shell_bak
    let &shellcmdflag=shellcmdflag_bak
    let &shellpipe=shellpipe_bak
    let &shellredir=shellredir_bak
    let &shellxquote=shellxquote_bak

    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  if a:cmd =~# '^l'
    botright lopen
  else
    botright copen
  endif
  redraw!
endfunction

command! -bang -nargs=* -complete=file FindString call s:FindString('grep<bang>',<q-args>)
