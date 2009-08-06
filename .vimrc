" Author: David Mohundro <drmohundro@gmail.com>
" Version: 1.1
" Url: http://www.mohundro.com/blog/

set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after

source $VIMRUNTIME/macros/matchit.vim

set history=100
set ruler
set number
set showcmd
set nowrap
set diffopt+=iwhite
set statusline=%f%m%r%h%w\ [%{&ff}]%y\ %=[%l,%v][%p%%]
set laststatus=2
set hidden
set title
set scrolloff=3
set nrformats=hex
set splitright
set splitbelow
set mouse=a
set shortmess=atI

" enable 256 color support in the terminal
set t_Co=256

" intuitive backspacing in insert mode
set backspace=indent,eol,start 

syntax on
filetype on
filetype plugin on
filetype indent on

set incsearch
set hlsearch

if has("gui_running")
	set cursorline
endif

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
		set gfn=DejaVu_Sans_Mono:h11:cANSI
	endif
endif

if has("gui_running")
	"color morning
	color jellybeans
else
	color pablo
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
map <leader>t :FuzzyFinderTag<Return>
map <C-T> :FuzzyFinderTextMate<Return>
map <C-N> :FuzzyFinderFile<Return>
map <C-L> :FuzzyFinderBuffer<Return>

" taglist settings
let tlist_vbnet_settings = 'vbnet;s:subroutine;f:function;n:name;e:enum'

nnoremap ' `
nnoremap ` '

nnoremap J <C-d>
nnoremap K <C-u>

nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

nnoremap <esc> :noh<return><esc>

map H ^
map L $

set listchars=tab:>-,trail:.,eol:$
nmap <silent> <leader>s :set nolist!<CR>

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal g'\"" |
\ endif

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
autocmd BufNewFile,BufRead *.psm1 set ft=ps1
autocmd BufNewFile,BufRead *.xaml set ft=xml
autocmd BufNewFile,BufRead *.config set ft=xml
autocmd BufNewFile,BufRead *.ps1xml set ft=xml
autocmd BufNewFile,BufRead *.vbproj set ft=xml
autocmd BufNewFile,BufRead *.csproj set ft=xml

" Stop beeping and flashing!
autocmd VimEnter * set vb t_vb=

"
" XMLEdit Settings
"
let xml_use_xhtml = 1

" taglist plugin Settings (from http://dancingpenguinsoflight.com/2009/02/code-navigation-completion-snippets-in-vim/)
let g:ctags_statusline = 1
let generate_tags = 1
let Tlist_Use_Horiz_Window = 0
nnoremap TT :TlistToggle<CR>
map <F4> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_Compact_Format = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1

" customize backup directories
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
