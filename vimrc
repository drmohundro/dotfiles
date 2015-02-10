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
Bundle 'IndexedSearch'
Bundle 'JavaScript-Indent'
Bundle 'mru.vim'
" }}}2
" Section: Colors {{{2
Bundle 'altercation/vim-colors-solarized'
Bundle 'chriskempson/base16-vim'
Bundle 'jnurmine/Zenburn'
Bundle 'MaxSt/FlatColor'
Bundle 'tomasr/molokai'
Bundle 'tpope/vim-vividchalk'
" }}}2
" Section: FileTypes {{{2
Bundle 'kongo2002/fsharp-vim'
Bundle 'pangloss/vim-javascript'
Bundle 'PProvost/vim-ps1'
Bundle 'Keithbsmiley/swift.vim'

Bundle 'vim-pandoc/vim-pandoc'
Bundle 'vim-pandoc/vim-pandoc-syntax'
Bundle 'vim-pandoc/vim-pandoc-after'
let g:pandoc#after#modules#enabled = ["nrrwrgn", "supertab"]
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

Bundle 'justinmk/vim-sneak'
Bundle 'jlanzarotta/bufexplorer'
let g:bufExplorerFindActive = 0

Bundle 'junegunn/vim-peekaboo'

Bundle 'ctrlpvim/ctrlp.vim'
if has('win32')
  let g:ctrlp_user_command = ['.git', 'cd %s & git ls-files . -co --exclude-standard', 'pt %s -l --no-color -g ""']
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'pt %s -l --no-color -g ""']
end

Bundle 'majutsushi/tagbar'
Bundle 'mattn/emmet-vim'

Bundle 'OmniSharp/omnisharp-vim'
" also requires syntastic
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

if has('mac')
  Bundle 'rizzatti/dash.vim'
end

Bundle 'rking/ag.vim'
" Configure ag.vim to use pt.exe instead
let g:agprg="pt --nogroup"
let g:agformat="%f:%l:%m"

Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
" open NERDTree on right side
let NERDTreeWinPos = 'right'
let NERDTreeHijackNetrw = 0

Bundle 'jistr/vim-nerdtree-tabs'
let g:nerdtree_tabs_open_on_gui_startup = 0

Bundle 'scrooloose/syntastic'
Bundle 'sheerun/vim-polyglot'
Bundle 't9md/vim-choosewin'
let g:choosewin_overlay_enable = 1

Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-vinegar'

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
xnoremap J <c-d>
nnoremap K <c-u>
xnoremap K <c-u>

" use standard regular expressions instead of out of the box vim
nnoremap / /\v
xnoremap / /\v

" up/down work as expected with word wrapping on
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" H/L go to beginning/end of line
map H ^
map L $

" indent in visual mode with <tab>
xnoremap <tab> >gv
xnoremap <s-tab> <gv

" hide search highlighting with <esc>
nnoremap <esc> :nohlsearch<cr><esc>

" toggle commenting with \\
map \\ <plug>NERDCommenterInvert

" show buffer list
map <c-l> :BufExplorer<cr>

" show tag bar drawer
map <F4> :TagbarToggle<cr>

" choosewin
nmap <leader>w <Plug>(choosewin)

" toggle NERDTree drawer
nnoremap <leader>d :NERDTreeTabsToggle<cr>

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
xnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

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
  augroup OmniSharpCommands "{{{2
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    autocmd FileType cs nnoremap <C-b> :OmniSharpGotoDefinition<cr>
  augroup END "}}}2
endif

" }}}1
" Section: GUI {{{1

set background=dark
color molokai

"set background=light
"color solarized

if has("gui_running")
  set cursorline           " highlight current line
  set guioptions=egt
  set guioptions+=c        " c = console dialogs

  set lines=44
  set columns=126

  if has("mac")
    set guifont=Source\ Code\ Pro:h14
  elseif has("unix")
    set guifont=Mono\ 14
  elseif has("win32")
    set guifont=Source_Code_Pro:h11
    set renderoptions=type:directx,gamma:1.0,contrast:0.2,level:1.0,geom:1,renmode:5,taamode:1
  endif
else
  if has("win32")
    " see http://stackoverflow.com/a/14434531/4570
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    color molokai
  endif
endif

" }}}1

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
