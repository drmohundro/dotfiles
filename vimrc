" Author: David Mohundro <david@mohundro.com>
" Url: http://mohundro.com/blog/

" this has to be set early so that alt keybindings will work in Windows
set encoding=utf-8
scriptencoding utf-8

if has('win32')
  set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after
end

" Section: Vim-Plug {{{1
call plug#begin('~/.vim/plugged')

" Section: Colors {{{2
Plug 'altercation/vim-colors-solarized'
Plug 'tomasr/molokai'
Plug 'tpope/vim-vividchalk'
Plug 'NLKNguyen/papercolor-theme'
" }}}2
" Section: FileTypes {{{2
" general
Plug 'sheerun/vim-polyglot'

" specific
Plug 'OrangeT/vim-csharp'
Plug 'tpope/vim-markdown'
let g:markdown_fenced_languages = ['coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'html']
" }}}2

Plug 'bling/vim-airline'
" use powerline patched fonts
let g:airline_powerline_fonts = 0
let g:airline_left_sep=''
let g:airline_right_sep=''

Plug 'chrisbra/NrrwRgn'

" use background color for hex colors
Plug 'chrisbra/Colorizer'
" automatic colorization filetypes
let g:colorizer_auto_filetype='css,html,cshtml'

Plug 'editorconfig/editorconfig-vim'

" add in nvim GUI shim support
Plug 'equalsraf/neovim-gui-shim'

Plug 'justinmk/vim-sneak'
Plug 'jlanzarotta/bufexplorer'
let g:bufExplorerFindActive = 0
let g:bufExplorerShowNoName = 1

if isdirectory($HOME . '/.fzf')
  Plug '~/.fzf'
elseif isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf'
end

Plug 'junegunn/fzf.vim'

" show register contents
Plug 'junegunn/vim-peekaboo'

" plugin to place, toggle and display marks
Plug 'kshenoy/vim-signature'

Plug 'machakann/vim-highlightedyank'
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim'

Plug 'mileszs/ack.vim'
" use ripgrep instead
let g:ackprg = 'rg --vimgrep --smart-case --no-heading'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
" open NERDTree on right side
let g:NERDTreeWinPos = 'right'
let g:NERDTreeHijackNetrw = 0

Plug 't9md/vim-choosewin'
let g:choosewin_overlay_enable = 1

Plug 'tpope/vim-abolish'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-repeat'

if !has('nvim')
  Plug 'tpope/vim-sensible'
end

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'

Plug 'vim-scripts/IndexedSearch'

Plug 'w0rp/ale'

let g:ale_fixers = {
\  'javascript': ['prettier'],
\  'markdown': ['prettier'],
\}

let g:ale_linters = {
\  'javascript': ['eslint'],
\}

let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1

if !has('win32')
  let g:ale_sign_error = '❌'
  let g:ale_sign_warning = '⚠️'

  let g:airline#extensions#ale#error_symbol = '❌ '
  let g:airline#extensions#ale#warning_symbol = '⚠ '
end

Plug 'yegappan/mru'

call plug#end()
" }}}1

syntax on

" Section: Options {{{1

set clipboard=unnamed      " default to system clipboard
set foldmethod=marker      " fold on markers by default
set foldlevelstart=99      " don't default to open files folded
set hlsearch               " highlight search results
set hidden
set ignorecase             " ignore case when searching
set number                 " show line numbers
set relativenumber         " use relative numbers outside of current number
set smartcase              " override ignore case if searching for mixed case
set wildmode=longest,list  " list all matches and complete each full match

set tabstop=2              " 2 space tabs
set shiftwidth=2           " autoindent 2 spaces
set expandtab              " use spaces instead of tabs

set nobackup
set noswapfile

set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

set listchars=tab:»\ ,trail:·,eol:↲,
set nomodeline
set showbreak=>\
set winaltkeys=no

if has('nvim')
  set inccommand=split     " preview replacements commands in a split (and live window)
end

if !has('win32')
  " avoid warnings when I'm using fish
  set shell=bash
endif

set diffopt+=internal,algorithm:patience

set wildignore+=.hg,.git,.svn,*.swp
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
set wildignore+=*.exe,*.dll,*.pdb,*.suo

let g:netrw_liststyle=1    " default netrw to long style (file size, timestamp, etc.)

" {{{2 Coc.vim

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use gp for show documentation in preview window
nnoremap <silent> gp :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" }}}2

" }}}1
" Section: Mappings {{{1

let g:mapleader=','

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
nnoremap <leader>d :NERDTreeToggle<cr>

map <c-p> :FZF<cr>

if !has('nvim')
  map y <Plug>(highlightedyank)
end

" Section: Functions {{{1

" Increase/decrease the font size
if (&t_Co > 2 || has('gui_running')) && has('syntax')
  command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
  command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
  noremap <M-,> :Smaller<CR>
  noremap <M-.> :Bigger<CR>
endif

" In visual mode, search for selected text under cursor
function! s:VSetSearch()
  let l:temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = l:temp
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

" Yank current file's path to clipboard
function! YankCurrentFile()
  let @* = expand('%:p')
endfunction
command! -bar YankCurrentFile :execute YankCurrentFile()

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

autocmd VimEnter * set vb t_vb= " Stop beeping and flashing!

augroup AutoSave
  autocmd!
  " via http://stackoverflow.com/questions/2400264/is-it-possible-to-apply-vim-configurations-without-restarting/2400289#2400289 and @nelstrom
  autocmd BufWritePost .vimrc,_vimrc,vimrc so $MYVIMRC
augroup END

" }}}1
" Section: GUI {{{1

if !has('win32') || has('nvim')
  " enable nice colors in nvim
  set termguicolors
end

set background=dark
color molokai

"set background=light
"color PaperColor

if has('gui_running')
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
endif

" }}}1

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
