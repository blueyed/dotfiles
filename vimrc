" based on http://github.com/jferris/config_files/blob/master/vimrc

" TODO: install https://github.com/vim-scripts/xterm-color-table.vim

set runtimepath=~/.vim,$VIMRUNTIME  "Use instead of "vimfiles" on windows

" Local dirs
set backupdir=~/.vim/backups
if has('persistent_undo')
	set undodir=~/.vim/undo
	set undofile
endif
set shellslash
"exec '!mkdir ' . shellescape(&backupdir)
"exec '!mkdir ' . shellescape(&directory)
"exec '!mkdir ' . shellescape(&undodir)


if has("user_commands")
	" enable pathogen, which allows bundles in vim/bundle
	call pathogen#runtime_append_all_bundles()
	call pathogen#helptags()
endif


" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set encoding=utf8

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup
set nowritebackup
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
  set hlsearch
endif

" Switch wrap off for everything
set nowrap

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Set File type to 'text' for files ending in .txt
  autocmd BufNewFile,BufRead *.txt setfiletype text

  " Typoscript file type
  au BufNewFile,BufRead *.ts setfiletype=typoscript

  " Enable soft-wrapping for text files
  autocmd FileType text,markdown,html,xhtml,eruby setlocal wrap linebreak nolist

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Automatically load .vimrc source when saved
  autocmd BufWritePost .vimrc source $MYVIMRC

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" if has("folding")
  " set foldenable
  " set foldmethod=syntax
  " set foldlevel=1
  " set foldnestmax=2
  " set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '
" endif

set tabstop=2
set shiftwidth=2
set noexpandtab
if has("autocmd")
	" Expand tabs for Debian changelog. This is probably not the correct way.
	au BufNewFile,BufRead debian/changelog,changelog.dch set expandtab
endif

" Always display the status line
set laststatus=2
set statusline=%F%m%r%{fugitive#statusline()}%h%w\ [%{&ff}]\ [%Y]\ [\%03.3b]\ [%04l,%04v][%p%%]\ [%L\ lines\]

if 1 " has('eval')
	let mapleader = ","
endif

" Edit the README_FOR_APP (makes :R commands work)
"map <Leader>R :e doc/README_FOR_APP<CR>

" Leader shortcuts for Rails commands
"map <Leader>m :Rmodel
"map <Leader>c :Rcontroller
"map <Leader>v :Rview
"map <Leader>u :Runittest
"map <Leader>f :Rfunctionaltest
"map <Leader>tm :RTmodel
"map <Leader>tc :RTcontroller
"map <Leader>tv :RTview
"map <Leader>tu :RTunittest
"map <Leader>tf :RTfunctionaltest
"map <Leader>sm :RSmodel
"map <Leader>sc :RScontroller
"map <Leader>sv :RSview
"map <Leader>su :RSunittest
"map <Leader>sf :RSfunctionaltest

" Hide search highlighting
map <Leader>h :set invhls <CR>

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>t
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Duplicate a selection
" Visual mode: D
vmap D y'>p

" Press Shift+P while in visual mode to replace the selection without
" overwriting the default register
vmap P p :call setreg('"', getreg('0')) <CR>

if has("autocmd")
	au! BufRead,BufNewFile *.haml         setfiletype haml
endif

" No Help, please
nmap <F1> <Esc>

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

" Maps autocomplete to tab
" imap <Tab> <C-N>

imap <C-L> <Space>=><Space>

" Display extra whitespace
set list listchars=tab:»·,trail:·,eol:¬,nbsp:_
set fillchars=fold:-
nnoremap <silent> <leader>c :set nolist!<CR>
set nolist

" Paste toggle (,p)
set pastetoggle=<leader>p
map <leader>p :set invpaste paste?<CR>


" Local config
if filereadable(".vimrc.local")
  source .vimrc.local
endif

" Use Ack instead of Grep when available
if executable("ack")
  set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
else
	" this is for Windows/cygwin and to add -H
	set grepprg=grep\ -nH\ $*\ /dev/null
endif

" Color scheme
silent! colorscheme desert256
" highlight NonText guibg=#060606
" highlight Folded  guibg=#0A0A0A guifg=#9090D0

" Line numbers
set nonumber
set numberwidth=5

" Snippets are activated by Shift+Tab
" let g:snippetsEmu_key = "<S-Tab>"

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
set completeopt=longest,menu
set wildmode=list:longest,list:full
set complete=.,t

" case only matters with mixed case expressions
set ignorecase smartcase

" being smart helps
set smarttab smartindent

" Tags
if 1 " has('eval')
	let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"
endif
set tags=./tags;

if 1 " has('eval')
	let g:fuf_splitPathMatching=1
endif


set cursorline
"highlight CursorLine guibg=lightblue ctermbg=lightgray

" Look for tags file in parent directories, upto "/"
set tags+=tags;/

if has("osfiletype")
	filetype plugin indent on
endif

" via http://www.reddit.com/r/programming/comments/7yk4i/vim_settings_per_directory/c07rk9d
" :au! BufRead,BufNewFile *path/to/project/*.* setlocal noet

set hidden

" consider existing windows and tabs when opening files, e.g. from quickfix
set switchbuf=usetab

" Maps for jj to act as Esc
ino jj <esc>
cno jj <c-c>

" close tags (useful for html)
imap <Leader>/ </<C-X><C-O>



" Strip trailing whitespace (,ss)
function! StripWhitespace ()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace ()<CR>

if exists('+relativenumber')
	set relativenumber " Use relative line numbers. Current line is still in status bar.
	au BufReadPost * set relativenumber
endif

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Sudo write (,W)
noremap <leader>W :w !sudo tee %<CR>

" Easy indentation in visual mode
" This keeps the visual selection active after indenting.
" Usually the visual selection is lost after you indent it.
vmap > >gv
vmap < <gv

" Syntax Checking entire file (Python)
" Usage: :make (check file)
" :clist (view list of errors)
" :cn, :cp (move around list of errors)
autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" add semicolon to end of line if there is none
noremap ; :s/\([^;]\)$/\1;/<cr>

" source ~/.vim/source.d/*.vim
" exe join(map(split(glob("~/.vim/source.d/*.vim"), "\n"), '"source " . v:val'), "\n")
runtime! source.d/*.vim


" defined in php-doc.vim
nnoremap <Leader>d :call PhpDocSingle()<CR>

" Open Windows explorer and select current file
command! Winexplorer :!start explorer.exe /e,/select,"%:p:gs?/?\\?"

noremap <Leader>n :NERDTreeToggle<cr>

set wildmenu
set sessionoptions+=unix,slash " for unix/windows compatibility

" Open URL
if has("user_commands")
command! -bar -nargs=1 OpenURL :!open <args>
function! OpenURL()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
  echo s:uri
  if s:uri != ""
	  exec "!open \"" . s:uri . "\""
  else
	  echo "No URI found in line."
  endif
endfunction
map <Leader>w :call OpenURL()<CR>
endif

if filereadable("~/.vimrc.local")
	source "~/.vimrc.local"
endif
