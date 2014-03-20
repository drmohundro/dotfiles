" Author: David Mohundro <david@mohundro.com>
" Version: 1.4
" Url: http://mohundro.com/blog/

set nocompatible
if has("win32")
  set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after
end
filetype off

" Section: Vundle {{{1
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Bundle 'gmarik/vundle'

" Section: Vim-Scripts {{{2
Bundle 'bufexplorer.zip'
Bundle 'IndexedSearch'
Bundle 'JavaScript-Indent'
Bundle 'mru.vim'
" }}}2
" Section: Colors {{{2
Bundle 'altercation/vim-colors-solarized'
Bundle 'chriskempson/base16-vim'
Bundle 'tomasr/molokai'
Bundle 'tpope/vim-vividchalk'
" }}}2
" Section: FileTypes {{{2
Bundle 'kongo2002/fsharp-vim'
Bundle 'pangloss/vim-javascript'
Bundle 'PProvost/vim-ps1'
" }}}2

Bundle 'bling/vim-airline'
" use powerline patched fonts
let g:airline_powerline_fonts = 0
let g:airline_left_sep=''
let g:airline_right_sep=''

Bundle 'chrisbra/NrrwRgn.git'
Bundle 'chrisbra/color_highlight'
" automatic colorization filetypes
let g:colorizer_auto_filetype='css,html,cshtml'

Bundle 'ciaranm/detectindent'
Bundle 'drmohundro/find-string.vim'
Bundle 'ervandew/supertab'
" Let SuperTab try to determine best completion based on context, whether
" <C+X><C+O> or something else.
let g:SuperTabDefaultCompletionType = "context"

Bundle 'itchyny/calendar.vim'
Bundle 'justinmk/vim-sneak'
Bundle 'kien/ctrlp.vim'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

Bundle 'majutsushi/tagbar'
Bundle 'mattn/emmet-vim'
Bundle 'mileszs/ack.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
" open NERDTree on right side
let NERDTreeWinPos = 'right'

Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-surround'

if !has('win32')
  Bundle 'Valloric/YouCompleteMe'
else
  Bundle 'Shougo/neocomplete.vim'
  " enable neocomplete
  let g:neocomplete#enable_at_startup = 1
endif
" }}}1

syntax on
filetype plugin indent on

" Section: Options {{{1

set clipboard=unnamed      " default to system clipboard
set foldmethod=marker      " fold on markers by default
set hlsearch               " highlight search results
set ignorecase             " ignore case when searching
set number                 " show line numbers
set relativenumber         " use relative numbers outside of current number
set smartcase              " override ignore case if searching for mixed case
set wildmode=longest,list  " list all matches and complete each full match

set tabstop=2           " 2 space tabs
set shiftwidth=2        " autoindent 2 spaces
set expandtab           " use spaces instead of tabs

set backupdir=$TEMP,$TMP,.   " where to store backups
set directory=$TEMP,$TMP,.   " where to store swp files

" TODO: get comments on these or remove them
set listchars=tab:>-,trail:·,eol:¬
set showbreak=>\
set winaltkeys=no

set wildignore+=.hg,.git
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
set wildignore+=*.exe,*.dll,*.pdb,*.suo

" }}}1
" Section: Mappings {{{1

let mapleader=","

" Toggle showing whitespace or not
nmap <silent> <leader>s :set nolist!<cr>

nnoremap J <c-d>
vnoremap J <c-d>
nnoremap K <c-u>
vnoremap K <c-u>

" use standard regular expressions instead of out of the box vim
nnoremap / /\v
vnoremap / /\v

" up/down work as expected with word wrapping on
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" H/L go to beginning/end of line
map H ^
map L $

" indent in visual mode with <tab>
vnoremap <tab> >gv
vnoremap <s-tab> <gv

" hide search highlighting with <esc>
nnoremap <esc> :nohlsearch<cr><esc>

" toggle commenting with \\
map \\ <plug>NERDCommenterInvert

" show buffer list
map <c-l> :BufExplorer<cr>

" show tag bar drawer
map <F4> :TagbarToggle<cr>

" toggle NERDTree drawer
nnoremap <leader>d :NERDTreeToggle<cr>

" Section: Functions {{{1

" Increase/decrease the font size
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

" Autowrap lines around column 80
function! AutowrapLines()
  set textwidth=78
  set formatoptions=cqt
  set wrapmargin=0
endfunction
command! -bar AutowrapLines :execute AutowrapLines()

" Set tabstop, softtabstop and shiftwidth to the same value
function! Stab()
  let l:tabstop = 1 * input('set tabstop = softtabstop = shiftwidth = ')
  if l:tabstop > 0
    let &l:sts = l:tabstop
    let &l:ts = l:tabstop
    let &l:sw = l:tabstop
  endif
  call SummarizeTabs()
endfunction
command! -nargs=* Stab call Stab()

" Display current tab settings
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
    autocmd FileType * DetectIndent

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
" Section: GUI {{{1

color molokai
if has("gui_running")
  set cursorline           " highlight current line
  set guioptions=egt
  set guioptions+=c        " c = console dialogs

  set lines=44
  set columns=126

  if has("mac")
    set guifont=Inconsolata\ for\ Powerline:h16
  elseif has("unix")
    set guifont=Mono\ 14
  elseif has("win32")
    set guifont=Source_Code_Pro:h11
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
