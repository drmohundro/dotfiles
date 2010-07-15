" Author: David Mohundro <drmohundro@gmail.com>
" Version: 1.3
" Url: http://www.mohundro.com/blog/
"
" Notes:
" Significant portions of this are courtesy of Tim Pope's vim settings from http://git.tpope.net/tpope.git

" Section: Options {{{1
if has("win32")
  set runtimepath=~/.vim,$VIMRUNTIME
end

silent! call pathogen#runtime_append_all_bundles()
" silent! call pathogen#runtime_prepend_subdirectories("~/src/vim/bundle")

set tabstop=2
set shiftwidth=2

set nocompatible
set history=100
set number
set autoindent
set backspace=indent,eol,start    " intuitive backspaceing
set showbreak=>\  
set clipboard=unnamed             " default to the system clipboard
set display=lastline
set expandtab
set hidden
set hlsearch
set incsearch
set laststatus=2
set listchars=tab:>-,trail:.,eol:$
set mousemodel=popup
set scrolloff=3
set showcmd
set showmatch
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%{exists('*rails#statusline')?rails#statusline():''}%{exists('*fugitive#statusline')?fugitive#statusline():''}%#ErrorMsg#%{exists('*SyntasticStatuslineFlag')?SyntasticStatuslineFlag():''}%*%=%-16(\ %l,%c-%v\ %)%P
set ignorecase
set smartcase
set smarttab
set splitbelow
set splitright
set spelllang=en_us
set wildmenu
set wildmode=list:longest
set winaltkeys=no
set foldmethod=marker
set mouse=a
set virtualedit=block
set lines=44
set columns=126

set t_Co=256                      " enable 256 color support in the terminal

syntax on
filetype plugin indent on

set backupdir=$TEMP,$TMP,.
set directory=$TEMP,$TMP,.

" Plugin Options: {{{2

let MRU_Max_Entries = 50
let NERDTreeWinPos = 'right'
let xml_use_xhtml = 1
let xml_use_html = 1

" }}}2
" }}}1
" Section: Commands {{{1

if has("eval")
  command! -bar -nargs=0 -bang Scratch :silent edit<bang> \[Scratch]|set buftype=nofile bufhidden=hide noswapfile buflisted
  command! -bar -nargs=* -bang -complete=file Rename :
        \ let v:errmsg = ""|
        \ saveas<bang> <args>|
        \ if v:errmsg == ""|
        \   call delete(expand("#"))|
        \ endif
  command! -bar Invert :let &background = (&background=="light"?"dark":"light")

  function! OpenURL(url)
    if has("win32")
      exe "!start cmd /cstart /b ".a:url.""
    elseif $DISPLAY !~ '^\w'
      exe "silent !sensible-browser \"".a:url."\""
    else
      exe "silent !sensible-browser -T \"".a:url."\""
    endif
    redraw!
  endfunction
  command! -nargs=1 OpenURL :call OpenURL(<q-args>)

  function! Run()
    let old_makeprg = &makeprg
    let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
    if exists("b:run_command")
      exe b:run_command
    elseif cmd != '' && executable(cmd)
      wa
      let &makeprg = matchstr(getline(1),'^#!\zs.*').' %'
      make
    elseif &ft == "mail" || &ft == "text" || &ft == "help" || &ft == "gitcommit"
      setlocal spell!
    elseif exists("b:rails_root") && exists(":Rake")
      wa
      Rake
    elseif &ft == "ruby"
      wa
      if executable(expand("%:p")) || getline(1) =~ '^#!'
        compiler ruby
        let &makeprg = "ruby"
        make %
      elseif expand("%:t") =~ '_test\.rb$'
        compiler rubyunit
        let &makeprg = "ruby"
        make %
      elseif expand("%:t") =~ '_spec\.rb$'
        compiler ruby
        let &makeprg = "spec"
        make %
      else
        !irb -r"%:p"
      endif
    elseif &ft == "html" || &ft == "xhtml" || &ft == "php" || &ft == "aspvbs" || &ft == "aspperl"
      wa
      if !exists("b:url")
        call OpenURL(expand("%:p"))
      else
        call OpenURL(b:url)
      endif
    elseif &ft == "vim"
      wa
      unlet! g:loaded_{expand("%:t:r")}
      return 'source %'
    elseif &ft == "sql"
      1,$DBExecRangeSQL
    elseif expand("%:e") == "tex"
      wa
      exe "normal :!rubber -f %:r && xdvi %:r >/dev/null 2>/dev/null &\<CR>"
    else
      wa
      if &makeprg =~ "%"
        make
      else
        make %
      endif
    endif
    let &makeprg = old_makeprg
    return ""
  endfunction
  command! -bar Run :execute Run()

  function! s:VSetSearch()
      let temp = @@
      norm! gvy
      let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
      let @@ = temp
  endfunction
  vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
  vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>
endif

" }}}1
" Section: Mappings {{{1
let mapleader=","

nmap <silent> <leader>s :set nolist!<CR>

nnoremap J <C-d>
vnoremap J <C-d>
nnoremap K <C-u>
vnoremap K <C-u>

nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

map H ^
map L $

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

map \\ <Plug>NERDCommenterInvert
map <C-l> :FufBuffer<CR>
map <M-t> :CommandT<CR>

let Tlist_Use_Right_Window = 1
map <F4> :TlistToggle<CR>

nnoremap <Esc> :noh<CR><Esc>
nnoremap <Leader>d :NERDTreeToggle<CR>
" }}}1
" Section: Autocommands {{{1

if has("autocmd")
  autocmd VimEnter * set vb t_vb=        " Stop beeping and flashing!

  augroup FTDetect " {{{2
    autocmd BufNewFile,BufRead *.vb set ft=vbnet
    autocmd BufNewFile,BufRead *.ps1 set ft=ps1
    autocmd BufNewFile,BufRead *.psm1 set ft=ps1
    autocmd BufNewFile,BufRead *.psd1 set ft=ps1
    autocmd BufNewFile,BufRead *.md,*.markdown set ft=mkd
    autocmd BufNewFile,BufRead *.json set ft=javascript
    autocmd BufNewFile,BufRead *.txt,README,INSTALL,TODO if &ft == "" | set ft=text | endif
  augroup END "}}}2
  augroup FTOptions " {{{2
    autocmd FileType c,cpp,cs,java          setlocal ai et sta sw=4 sts=4 ts=4 cin
    autocmd FileType ps1                    setlocal ai et sta sw=4 sts=4 ts=4 cin cino+=+0 cink-=0#
    autocmd FileType sql,vbnet              setlocal ai et sta sw=4 sts=4 ts=4
    autocmd FileType javascript             setlocal ai et sta sw=2 sts=2 ts=2 cin isk+=$
    autocmd FileType vbnet                  runtime! indent/vb.vim
  augroup END " }}}2
endif

" }}}1
" Section: Visual {{{1

if has("gui_running")
  set cursorline
  color railscasts

  set guioptions=egt

  if has("mac")
    set guifont=Inconsolata:h20
  elseif has("unix")
    set guifont=Mono\ 14
  elseif has("win32")
    set guifont=Consolas:h12
  endif
else
  color pablo
endif

if (&t_Co > 2 || has("gui_running")) && has("syntax")
  command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
  command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
  noremap <M-,>        :Smaller<CR>
  noremap <M-.>        :Bigger<CR>
endif

" }}}1

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
