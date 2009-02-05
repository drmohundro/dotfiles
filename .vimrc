" Author: David Mohundro <drmohundro@gmail.com>
" Version: 1.1
" Url: http://www.mohundro.com/blog/

set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after

source $VIMRUNTIME/mswin.vim
behave mswin

source $VIMRUNTIME/macros/matchit.vim

set history=100
set ruler
set number
set showcmd
set nowrap
set diffopt+=iwhite
set laststatus=2
set hidden
set title
set scrolloff=3

set shortmess=atI

" intuitive backspacing in insert mode
set backspace=indent,eol,start 

syntax on
filetype on
filetype plugin on
filetype indent on

set incsearch
set hlsearch

if has("gui_win32")
	set shell=powershell.exe
	set shellcmdflag=-noprofile\ -c
	"set shellcmdflag=-c
	set shellpipe=>
	set shellredir=>
endif

set showmatch  " show matching braces

if has("gui_running")
	if has("gui_gtk2")
		"set gfn=DejuVu\ Sans\ Mono\ 14
		set gfn=Mono\ 14
	elseif has("gui_win32")
		"set gfn=Consolas:h13
		"set gfn=Envy_Code_R:h13
		set gfn=DejaVu_Sans_Mono:h12:cANSI
	endif
endif

if has("gui_running")
	"color ir_black
	color blackboard
	"color morning
else
	color impact
endif

set background=dark  " favor dark backgrounds

" set pretty autocomplete on commands
set wildmenu
set wildmode=list:longest

set clipboard=unnamed   " yank to clipboard

" if running gvim, default to a larger window
if has("gui_running")
	set lines=48
	set columns=120

	set guioptions-=T  " hide toolbar
	set guioptions-=m  " hide menu
endif

" spaces instead of tabs
" set expandtab

set tabstop=4
set shiftwidth=4

" be smart with indenting
set autoindent
set smartindent

" ignore case when performing searches (unless typed explicitly with mixed case)
set ignorecase
set smartcase

let mapleader=","

" FuzzyFinderTextMate settings
let g:fuzzy_ignore = "*.log;*.dll;*.pdb;*.exe;*.baml;*.cache;*.suo;**/obj/*;**/bin/Debug/*;_ReSharper*;*.resharper;*.user"
let g:fuzzy_matching_limit = 70

" ignore ruby warning from LustyExplorer
let g:LustyExplorerSuppressRubyWarning = 1

" Key mappings
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>
map <C-T> :FuzzyFinderTextMate<Return>
map <C-N> :FuzzyFinderFile<Return>
map <C-L> :FuzzyFinderBuffer<Return>

nnoremap ' `
nnoremap ` '

map H ^
map L $

set listchars=tab:>-,trail:.,eol:$
nmap <silent> <leader>s :set nolist!<CR>

if has("autocmd")
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal g'\"" |
  \ endif
endif

" Omnicomplete functions
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete

" Automatically figure out formatting
autocmd BufNewFile,BufRead *.vb set ft=vbnet
autocmd BufNewFile,BufRead *.ps1 set ft=ps1
autocmd BufNewFile,BufRead *.xaml set ft=xml
autocmd BufNewFile,BufRead *.config set ft=xml
autocmd BufNewFile,BufRead *.ps1xml set ft=xml
autocmd BufNewFile,BufRead *.vbproj set ft=xml
autocmd BufNewFile,BufRead *.csproj set ft=xml

"
" XMLEdit Settings
"
let xml_use_xhtml = 1

set backupdir=$TEMP,$TMP,.
set directory=$TEMP,$TMP,.

" 
" Don't autoindent with XMLEdit enabled
"
autocmd BufEnter *.xml setlocal indentexpr=

"
" Usage - :Shell <command>
" The result of the command will be put in a new vertical split scratch
" window.
"
command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  botright vnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1,a:cmdline)
  call setline(2,substitute(a:cmdline,'.','=','g'))
  execute 'silent $read !'.escape(a:cmdline,'%#')
  1
endfunction

" 
" (default with gvim installation on windows)
" Diff expressions when using vimdiff (vim -d)
"
set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
