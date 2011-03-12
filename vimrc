" based on http://github.com/jferris/config_files/blob/master/vimrc

" TODO: install https://github.com/vim-scripts/xterm-color-table.vim

" replace ~/vimfiles with ~/.vim in runtimepath
let &runtimepath = join( map( split(&rtp, ','), 'substitute(v:val, escape(expand("~/vimfiles"), "\\"), escape(expand("~/.vim"), "\\"), "g")' ), "," )

" Local dirs
set backupdir=~/.vim/backups
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
  if ! isdirectory(expand(&undodir))
    echo "Creating undodir ".&undodir
    call mkdir( shellescape(expand(&undodir)), "", 0700 )
  endif
endif
let g:session_directory='~/.vim/sessions'
" set shellslash " nicer for win32, but causes problems with shellescape (e.g. in the session plugin (:RestartVim))

if has("user_commands")
  filetype off " just in case it was activated before
  " enable pathogen, which allows bundles in vim/bundle
  call pathogen#runtime_append_all_bundles()
  command! Mkhelptags call pathogen#helptags()
endif


" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set encoding=utf8

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup
set nowritebackup
set history=1000
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching

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

" Color scheme
"silent! colorscheme desert256
silent! colorscheme xoria256
"silent! colorscheme xterm16
"set background=dark " gets messed up by desert256 scheme
" highlight NonText guibg=#060606
" highlight Folded  guibg=#0A0A0A guifg=#9090D0

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
  autocmd BufWritePost $MYVIMRC,~/.dotfiles/vimrc source $MYVIMRC
  augroup END

  au BufNewFile,BufRead *pentadactylrc*,*.penta set filetype=pentadactyl
else

  set autoindent    " always set autoindenting on

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

  " Python
  au FileType python setlocal tabstop=2 shiftwidth=4 expandtab textwidth=79 autoindent

  " C
  au FileType C setlocal formatoptions-=c formatoptions-=o formatoptions-=r
  fu! Select_c_style()
    if search('^\t', 'n', 150)
      setlocal shiftwidth=8 noexpandtab
    el
      setlocal shiftwidth=4 expandtab
    en
  endf
  au FileType c call Select_c_style()
  au FileType makefile setlocal noexpandtab

  " Whitespace highlighting
  map <silent> <leader>se :let g:MyAuGroupEOLWSactive = (synIDattr(synIDtrans(hlID("EOLWS")), "bg", "cterm") == -1)<cr>
        \:if ! g:MyAuGroupEOLWSactive \| hi clear EOLWS <cr>
        \else \| hi EOLWS ctermbg=red guibg=red \| endif<cr>
  let g:MyAuGroupEOLWSactive = 1
  augroup vimrcExEOLWS 
    au!
    highlight EOLWS ctermbg=red guibg=red
    autocmd InsertEnter *
          \ if g:MyAuGroupEOLWSactive |
          \ syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/ containedin=ALL |
          \ endif
    " highlight trailing whitespace, space before tab and tab not at the
    " beginning of the line (except in comments), only for normal buffers:
    autocmd InsertLeave,BufWinEnter * 
          \ if g:MyAuGroupEOLWSactive && &bt == "" |
          \ syn clear EOLWS |
          \ syn match EOLWS excludenl /\s\+$\| \+\ze\t/ containedin=ALLBUT,gitcommitDiff |
          \ endif
      " fails with gitcommit: filetype  | syn match EOLWS excludenl /[^\t]\zs\t\+/ containedin=ALLBUT,gitcommitComment
    " add this for Python:
    autocmd FileType python
          \ if g:MyAuGroupEOLWSactive |
          \ syn match EOLWS excludenl /^\t\+/ containedin=ALL |
          \ endif
  augroup END

  " syntax mode setup
  let python_highlight_all = 1
  let php_sql_query = 1
  let php_htmlInStrings = 1
endif

" Always display the status line
set laststatus=2
set statusline=%F%m%r%{fugitive#statusline()}%h%w\ [%{&ff}]\ [%Y]\ [\%03.3b]\ [%04l,%04v][%p%%]\ [%L\ lines\]

if 1 " has('eval')
  let mapleader = ","
endif

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

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

imap <C-L> <Space>=><Space>

" Display extra whitespace
set list listchars=tab:»·,trail:·,eol:¬,nbsp:_,extends:»,precedes:«
set fillchars=fold:-
" set showbreak=↪ " no required with line numbers
nnoremap <silent> <leader>sc :set list!<CR>
inoremap <silent> <leader>sc <C-o>:set list!<CR>
set nolist

" toggle settings, mnemonic "set paste", "set wrap", ..
set pastetoggle=<leader>sp
noremap <leader>sw :set wrap!<cr>
noremap <leader>ss :set spell!<cr>

" Use Ack instead of Grep when available
if executable("ack")
  set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
elseif executable("ack-grep")
  set grepprg=ack-grep\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
else
  " this is for Windows/cygwin and to add -H
  set grepprg=grep\ -nH\ $*\ /dev/null
endif

" Line numbers
set nonumber
set numberwidth=5
if exists('+relativenumber') " 7.3
  set relativenumber " Use relative line numbers. Current line is still in status bar.
	" do not use relative number for quickfix window
  au BufReadPost * if &bt == "quickfix" |
				\	  set number |
				\ else |
				\	  set relativenumber |
				\ endif
endif

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
set completeopt=longest,menu
set wildmode=list:longest,list:full

set wildmenu
" move cursor instead of selecting entries (wildmenu)
cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>

" case only matters with mixed case expressions
set ignorecase smartcase

" being smart helps
set smarttab
"set smartindent
" experimental: use cindent instead of smartindent
set cindent

" Tags
if 1 " has('eval')
  let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"
endif
set tags=./tags;
" Look for tags file in parent directories, upto "/"
set tags+=tags;/

if 1 " has('eval')
  let g:fuf_splitPathMatching=1
endif

set cursorline
"highlight CursorLine guibg=lightblue ctermbg=lightgray

" via http://www.reddit.com/r/programming/comments/7yk4i/vim_settings_per_directory/c07rk9d
" :au! BufRead,BufNewFile *path/to/project/*.* setlocal noet

set hidden

" consider existing windows (but not tabs) when opening files, e.g. from quickfix
set switchbuf=useopen

" Maps for jj to act as Esc
ino jj <esc>
cno jj <c-c>

" close tags (useful for html)
imap <Leader>/ </<C-X><C-O>


" Strip trailing whitespace
function! StripWhitespace ()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction
noremap <leader>st :call StripWhitespace ()<CR>

" swap previously selected text with currently selected one (via http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines#Visual-mode_swapping)
vnoremap <C-X> <Esc>`.``gvP``P

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Sudo write (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Easy indentation in visual mode
" This keeps the visual selection active after indenting.
" Usually the visual selection is lost after you indent it.
"vmap > >gv
"vmap < <gv

" Syntax Checking entire file (Python)
" Usage: :make (check file)
" :clist (view list of errors)
" :cn, :cp (move around list of errors)
" NOTE: should be provided by checksyntax plugin
" autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
" autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" add semicolon to end of line if there is none
noremap ; :s/\([^;]\)$/\1;/<cr>

" Map cursor keys in normal mode to navigate windows/tabs
" via http://www.reddit.com/r/vim/comments/flidz/partial_completion_with_arrows_off/c1gx8it
" nnoremap  <Down> <C-W>j
" nnoremap  <Up> <C-W>k
" nnoremap  <Right> <C-PageDown>
" nnoremap  <Left> <C-PageUp>

" defined in php-doc.vim
nnoremap <Leader>d :call PhpDocSingle()<CR>

" Open Windows explorer and select current file
command! Winexplorer :!start explorer.exe /e,/select,"%:p:gs?/?\\?"

noremap <Leader>n :NERDTreeToggle<cr>
noremap <F1> :tab<Space>:help<Space>
" ':tag {ident}' - difficult on german keyboard layout and not working in gvim/win32
noremap <F2> <C-]>
noremap <F3> :TRecentlyUsedFiles<cr>
noremap <F5> :GundoToggle<cr>


" taglist plugin
nnoremap <silent> <F8> :TlistToggle<CR>
"let Tlist_Process_File_Always = 1

" handling of matches items, like braces
set showmatch
set matchtime=3
" deactivated, causes keys to be ignored when typed too fast (?)
"inoremap } }<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ] ]<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ) )<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a

set sessionoptions+=unix,slash " for unix/windows compatibility
set nostartofline " do not go to start of line automatically when moving
set scrolloff=3
set sidescroll=1

" command-t plugin
let g:CommandTMaxFiles=50000
let g:CommandTMaxHeight=20
if has("autocmd") && exists(":CommandTFlush")
  " this is required for Command-T to pickup the setting(s)
  au VimEnter * CommandTFlush
endif
if (has("gui_running"))
  " use Alt-T in GUI mode
  map <M-t> :CommandT<CR>
  map <leader>t :CommandT<CR>
endif

" supertab
let g:SuperTabLongestEnhanced=1
let g:SuperTabLongestHighlight=1 " triggers bug with single match (https://github.com/ervandew/supertab/commit/e026bebf1b7113319fc7831bc72d0fb6e49bd087#commitcomment-297471)

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" setup b:VCSCommandVCSType
function! SetupVCSType()
  try
    call VCSCommandGetVCSType(bufnr('%'))
  catch /No suitable plugin/
  endtry
endfunction
" do not call it automatically for now: vcscommands behaves weird (changing
" dirs), and slows simple scrolling (?) down (that might be quickfixsigns
" though)
if exists("*VCSCommandVCSType")
"au BufRead * call SetupVCSType()
endif

" make search very magic by default (more PCRE style)
nnoremap / /\v
vnoremap / /\v

nmap <tab> %
" conflicts with snipMate: vmap <tab> %

" edit vimrc shortcut
nnoremap <leader>ev <C-w><C-s><C-l>:e $MYVIMRC<cr>

let g:snips_author = "Daniel Hahler"

let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Utility functions to create file commands
" Source: https://github.com/carlhuda/janus/blob/master/gvimrc
" function! s:CommandCabbr(abbreviation, expansion)
"   execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
" endfunction

" Swap ' and ` keys (` is much more useful)
no ` '
no ' `

set formatoptions+=l " do not wrap lines that have been longer when starting insert mode already

let g:LustyExplorerSuppressRubyWarning = 1 " suppress warning when vim-ruby is not installed

" source http://vim.wikia.com/wiki/Switching_case_of_characters
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ ygv"=TwiddleCase(@")<CR>Pgv


" Open URL
nmap <leader>gw <Plug>(openbrowser-smart-search)
vmap <leader>gw <Plug>(openbrowser-smart-search)

" do not pick last item automatically (non-global: g:tmru_world.tlib_pick_last_item)
let g:tlib_pick_last_item = 0
let g:tlib_inputlist_match = 'fuzzy' " test

let vimcachedir=expand('~/.cache/vim')
if ! isdirectory(vimcachedir)
	call mkdir( vimcachedir, 'p', 0700 )
endif
let g:tlib_cache = vimcachedir . '/tlib'

let vimconfigdir=expand('~/.config/vim')
if ! isdirectory(vimconfigdir)
	call mkdir( vimconfigdir, 'p', 0700 )
endif
let g:session_directory = vimconfigdir . '/sessions'

" source ~/.vim/source.d/*.vim
" exe join(map(split(glob("~/.vim/source.d/*.vim"), "\n"), '"source " . v:val'), "\n")
" TODO: move to plugins
runtime! source.d/*.vim


" Local config
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
