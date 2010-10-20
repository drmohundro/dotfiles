" Author: David Mohundro <drmohundro@gmail.com>
" Version: 1.4
" Url: http://www.mohundro.com/blog/

" Section: Hacks/Fixes {{{1

if has("win32")
  " This fixes an issue that seems to affect win32 machines with Ruby 1.9.1 and
  " Vim 7.3 related to %PROGRAMFILES%\Vim\vim73\ftplugin\ruby.vim
  let g:ruby_path = "C:/Ruby191/lib/ruby/gems/1.9.1/gems/builder-2.1.2/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/fakefs-0.2.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/gemcutter-0.6.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/git-1.2.5/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/jeweler-1.4.0/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/jeweler-1.4.0/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/json_pure-1.4.6/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/json_pure-1.4.6/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/nokogiri-1.4.3.1-x86-mingw32/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/nokogiri-1.4.3.1-x86-mingw32/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rack-1.2.1/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rack-1.2.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rake-0.8.7/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rake-0.8.7/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rdiscount-1.6.5/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rdiscount-1.6.5/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/redgreen-1.2.2/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rspec-1.3.0/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rspec-1.3.0/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rubyforge-2.0.4/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rubyforge-2.0.4/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/test_notifier-0.3.4/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/toto-0.4.6/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/win32console-1.3.0-x86-mingw32/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/win32console-1.3.0-x86-mingw32/ext,C:/Ruby191/lib/ruby/gems/1.9.1/gems/win32console-1.3.0-x86-mingw32/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/ZenTest-4.4.0/bin,C:/Ruby191/lib/ruby/gems/1.9.1/gems/ZenTest-4.4.0/lib,C:/Ruby191/lib/ruby/site_ruby/1.9.1,C:/Ruby191/lib/ruby/site_ruby/1.9.1/i386-msvcrt,C:/Ruby191/lib/ruby/site_ruby,C:/Ruby191/lib/ruby/vendor_ruby/1.9.1,C:/Ruby191/lib/ruby/vendor_ruby/1.9.1/i386-msvcrt,C:/Ruby191/lib/ruby/vendor_ruby,C:/Ruby191/lib/ruby/1.9.1,C:/Ruby191/lib/ruby/1.9.1/i386-mingw32,.,C:/Ruby191/lib/ruby/gems/1.9.1/gems/ZenTest-4.4.0/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/builder-2.1.2/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/fakefs-0.2.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/gemcutter-0.6.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/git-1.2.5/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/jeweler-1.4.0/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/json_pure-1.4.6/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/nokogiri-1.4.3.1-x86-mingw32/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rack-1.2.1/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rake-0.8.7/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rdiscount-1.6.5/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/redgreen-1.2.2/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rspec-1.3.0/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/rubyforge-2.0.4/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/test_notifier-0.3.4/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/toto-0.4.6/lib,C:/Ruby191/lib/ruby/gems/1.9.1/gems/win32console-1.3.0-x86-mingw32/ext,C:/Ruby191/lib/ruby/gems/1.9.1/gems/win32console-1.3.0-x86-mingw32/lib"
end

" }}}1

if has("win32")
  " let me use ~/.vim on Windows, too
  set runtimepath=~/.vim,$VIMRUNTIME
end

filetype off
silent! call pathogen#runtime_append_all_bundles()

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
set gdefault                       " when replacing text, global is assumed (i.e. %s/foo/bar/ instead of %s/foo/bar/g)
set hlsearch
set ignorecase
set incsearch
set hidden
set history=100
set laststatus=2
set listchars=tab:>-,trail:.,eol:¬
set mouse=a
set mousemodel=popup
"set number
set relativenumber
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
set wildmode=list:longest
set winaltkeys=no

"set t_Co=256                      " enable 256 color support in the terminal

set backupdir=$TEMP,$TMP,.
set directory=$TEMP,$TMP,.

let MRU_Max_Entries = 50
let NERDTreeWinPos = 'right'
let Tlist_Use_Right_Window = 1

" }}}1
" Section: Commands {{{1

command! -bar -nargs=0 -bang Scratch :silent edit<bang> \[Scratch]|set buftype=nofile bufhidden=hide noswapfile buflisted
command! -bar -nargs=* -bang -complete=file Rename :
      \ let v:errmsg = ""|
      \ saveas<bang> <args>|
      \ if v:errmsg == ""|
      \   call delete(expand("#"))|
      \ endif
command! -bar Invert :let &background = (&background=="light"?"dark":"light")

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

command! -bar StripTrailingWhitespace :%s/\s\+$//

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
map <c-l> :FufBuffer<cr>
"map <m-t> :FuzzyFinderTextMate

"map <f4> :TlistToggle<cr>

nnoremap <leader>d :NERDTreeToggle<cr>

" }}}1
" Section: Autocommands {{{1

if has("autocmd")
  autocmd VimEnter * set vb t_vb= " Stop beeping and flashing!

  augroup FTDetect "{{{2
    autocmd BufNewFile,BufRead *.vb set ft=vbnet
    autocmd BufNewFile,BufRead *.ps1 set ft=ps1
    autocmd BufNewFile,BufRead *.psm1 set ft=ps1
    autocmd BufNewFile,BufRead *.psd1 set ft=ps1
    autocmd BufNewFile,BufRead *.md,*.markdown set ft=markdown
    autocmd BufNewFile,BufRead *.json set ft=javascript
    autocmd BufNewFile,BufRead *.build set ft=xml
    autocmd BufNewFile,BufRead *.txt,README,INSTALL,TODO if &ft == "" | set ft=text | endif
  augroup END "}}}2
  augroup FTOptions "{{{2
    autocmd FileType c,cpp,cs,java setlocal ai et sta sw=4 sts=4 ts=4 cin
    autocmd FileType ps1           setlocal ai et sta sw=4 sts=4 ts=4 cin cino+=+0 cink-=0#
    autocmd FileType sql,vbnet     setlocal ai et sta sw=4 sts=4 ts=4
    autocmd FileType javascript    setlocal ai et sta sw=2 sts=2 ts=2 cin isk+=$
    autocmd FileType vbnet         runtime! indent/vb.vim
  augroup END "}}}2

endif
" }}}1
" Section: Visual {{{1

if has("gui_running")
  set cursorline
  color railscasts

  set guioptions=egt

  set lines=44
  set columns=126

  if has("mac")
    set guifont=Inconsolata:h20
  elseif has("unix")
    set guifont=Mono\ 14
  elseif has("win32")
    set guifont=Inconsolata:h16
  endif
else
  color pablo
endif

" }}}1

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
