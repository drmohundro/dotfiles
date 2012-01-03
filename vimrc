" Author: David Mohundro <drmohundro@gmail.com>
" Version: 1.4
" Url: http://www.mohundro.com/blog/

call pathogen#infect()

" Section: Options {{{1

syntax on
filetype plugin indent on

set nocompatible

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set autoindent
set backspace=indent,eol,start     " intuitive backspacing
set clipboard=unnamed              " default to the system clipboard
set encoding=utf-8                 
set display=lastline
set foldmethod=marker
set hlsearch
set ignorecase
set incsearch
set hidden
set history=100
set laststatus=2
set listchars=tab:>-,trail:·,eol:¬
set mouse=a
set mousemodel=popup
set number
set scrolloff=3
set showbreak=>\
set showcmd
set showmatch
set smartcase
set smarttab
set splitbelow
set spelllang=en_us
set splitright
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%{exists('*rails#statusline')?rails#statusline():''}%{exists('*fugitive#statusline')?fugitive#statusline():''}%#ErrorMsg#%{exists('*SyntasticStatuslineFlag')?SyntasticStatuslineFlag():''}%*%=%-16(\ %l,%c-%v\ %)%P
set virtualedit=block
set wildmenu
set wildmode=longest,list
set winaltkeys=no

set backupdir=$TEMP,$TMP,.
set directory=$TEMP,$TMP,.

set wildignore+=.hg,.git
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
set wildignore+=*.exe,*.dll,*.pdb

let MRU_Max_Entries = 50
let NERDTreeWinPos = 'right'
let Tlist_Use_Right_Window = 1

if has("win32")
  let g:HammerDirectory = 'C:\Temp'
end

runtime macros/matchit.vim

" let g:CSApprox_verbose_level = 0

" }}}1
" Section: Commands {{{1

command! -bar -nargs=* -bang -complete=file Rename :
      \ let v:errmsg = ""|
      \ saveas<bang> <args>|
      \ if v:errmsg == ""|
      \   call delete(expand("#"))|
      \ endif

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

if (&t_Co > 2 || has("gui_running")) && has("syntax")
  command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
  command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
  noremap <M-,> :Smaller<CR>
  noremap <M-.> :Bigger<CR>
endif

" In visual mode, search for selected text under cursor
function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

command! -bar StripTrailingWhitespace :%s/\s\+$//

function! AutowrapLines()
  set textwidth=78
  set formatoptions=cqt
  set wrapmargin=0
endfunction
command! -bar AutowrapLines :execute AutowrapLines()

let g:solarized_style="dark"
function! ToggleBackground()
  if (g:solarized_style=="dark")
    let g:solarized_style="light"
    colorscheme mac_classic
    set background=light
  else
    let g:solarized_style="dark"
    colorscheme molokai
    set background=dark
  endif
endfunction
command! Togbg call ToggleBackground()

" Set tabstop, softtabstop and shiftwidth to the same value
command! -nargs=* Stab call Stab()
function! Stab()
  let l:tabstop = 1 * input('set tabstop = softtabstop = shiftwidth = ')
  if l:tabstop > 0
    let &l:sts = l:tabstop
    let &l:ts = l:tabstop
    let &l:sw = l:tabstop
  endif
  call SummarizeTabs()
endfunction

function! SummarizeTabs()
  try
    echohl ModeMsg
    echon 'tabstop='.&l:ts
    echon ' shiftwidth='.&l:sw
    echon ' softtabstop='.&l:sts
    if &l:et
      echon ' expandtab'
    else
      echon ' noexpandtab'
    endif
  finally
    echohl None
  endtry
endfunction

" }}}1
" Section: Mappings {{{1

let mapleader=","

nmap <silent> <leader>s :set nolist!<cr>

nnoremap J <c-d>
vnoremap J <c-d>
nnoremap K <c-u>
vnoremap K <c-u>

" use standard regular expressions instead of out of the box vim
nnoremap / /\v
vnoremap / /\v

nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

map H ^
map L $

vnoremap <tab> >gv
vnoremap <s-tab> <gv

nnoremap <esc> :noh<cr><esc>

map \\ <plug>NERDCommenterInvert
map <c-l> :BufExplorer<cr>

map <F4> :TagbarToggle<cr>

nnoremap <leader>d :NERDTreeToggle<cr>

" Section: Autocommands {{{1

if has("autocmd")
  autocmd VimEnter * set vb t_vb= " Stop beeping and flashing!

  augroup FTDetect "{{{2
    autocmd BufNewFile,BufRead *.vb set ft=vbnet
    autocmd BufNewFile,BufRead *.{ps1,psm1,psd1} set ft=ps1
    autocmd BufNewFile,BufRead *.{md,markdown} set ft=markdown
    autocmd BufNewFile,BufRead *.json set ft=javascript
    autocmd BufNewFile,BufRead *.cshtml set ft=cshtml
    autocmd BufNewFile,BufRead *.build set ft=xml
    autocmd BufNewFile,BufRead *.txt,README,INSTALL,TODO if &ft == "" | set ft=text | endif
  augroup END "}}}2
  augroup FTOptions "{{{2
    autocmd FileType * IndentDetect

    autocmd FileType c,cpp,cs,java setlocal ai et sta sw=4 sts=4 ts=4 cin
    autocmd FileType ps1           setlocal ai et sta sw=4 sts=4 ts=4 cin cino+=+0 cink-=0#
    autocmd FileType sql,vbnet     setlocal ai et sta sw=4 sts=4 ts=4
    autocmd FileType javascript    setlocal ai et sta sw=2 sts=2 ts=2 cin isk+=$
    autocmd FileType vbnet         runtime! indent/vb.vim
  augroup END "}}}2
  augroup MYVIMRCHooks "{{{2
    " via http://stackoverflow.com/questions/2400264/is-it-possible-to-apply-vim-configurations-without-restarting/2400289#2400289 and @nelstrom
    au!
    au BufWritePost .vimrc,_vimrc,vimrc so $MYVIMRC
  augroup END "}}}2

endif
" }}}1

" Section: Visual {{{1
set background=dark
color molokai
if has("gui_running")
  set cursorline
  set guioptions=egt
  set guioptions+=c

  set lines=44
  set columns=126

  if has("mac")
    set guifont=Inconsolata:h20
  elseif has("unix")
    set guifont=Mono\ 14
  elseif has("win32")
    set guifont=Envy_Code_R:h11
  endif
else
  if &t_Co != 256
    color pablo
  end
endif

" }}}1

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
