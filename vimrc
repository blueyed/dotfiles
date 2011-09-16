if 1 " has('eval')
  let mapleader = ","
  let g:my_full_name = "Daniel Hahler"

  let g:snips_author = g:my_full_name

  if has('win32') || has('win64')
    " replace ~/vimfiles with ~/.vim in runtimepath
    " let &runtimepath = join( map( split(&rtp, ','), 'substitute(v:val, escape(expand("~/vimfiles"), "\\"), escape(expand("~/.vim"), "\\"), "g")' ), "," )
    let &runtimepath = substitute(&runtimepath, '\('.escape($HOME, '\').'\)vimfiles\>', '\1.vim', 'g')
  endif

  " let g:sparkupExecuteMapping = '<Leader>e'
  " let g:sparkupNextMapping = '<Leader>ee'
  "
  let g:EasyMotion_leader_key = '<Leader>m'

  " autocomplpop: do not complete from dictionary; -= "k"
  " (manually trigger it by C-X C-K instead).
  let g:acp_completeOption = '.,w,b'

  " Syntastic
  let g:syntastic_enable_signs=1
  let g:syntastic_auto_jump=1
  let g:syntastic_auto_loc_list=1

  " syntax mode setup
  let python_highlight_all = 1
  let php_sql_query = 1
  let php_htmlInStrings = 1
endif

" Enable syntax {{{1
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
  set hlsearch
endif

if 1 " has('eval')
  " Color scheme (after 'syntax on') {{{1
  set background=dark
  set rtp+=~/.vim/bundle/solarized
  let g:solarized_termcolors=256
  let g:solarized_italic=0
  silent! colorscheme solarized
  " set rtp+=~/.vim/bundle/xoria256 " colorscheme
  " silent! colorscheme xoria256
endif

" Local dirs"{{{1
set backupdir=~/.local/share/vim/backups
if ! isdirectory(expand(&backupdir))
  call mkdir( &backupdir, 'p', 0700 )
endif

if 1
  let vimcachedir=expand('~/.cache/vim')
  if ! isdirectory(vimcachedir)
    echo "Creating cache dir ".vimcachedir
    call mkdir( vimcachedir, 'p', 0700 )
  endif
  let g:tlib_cache = vimcachedir . '/tlib'

  let vimconfigdir=expand('~/.config/vim')
  if ! isdirectory(vimconfigdir)
    echo "Creating config dir ".vimconfigdir
    call mkdir( vimconfigdir, 'p', 0700 )
  endif
  let g:session_directory = vimconfigdir . '/sessions'"

  let vimsharedir = expand('~/.local/share/vim')
  let g:yankring_history_dir = vimsharedir
  let g:yankring_max_history = 500
  " let g:yankring_min_element_length = 2 " more that 1 breaks e.g. `xp`
  " Move yankring from old location, if any..
  let s:old_yankring = expand('~/yankring_history_v2.txt')
  if filereadable(s:old_yankring)
    execute '!mv '.s:old_yankring.' '.vimsharedir
  endif
end

if has('persistent_undo')
  let &undodir = vimsharedir . '/undo'
  set undofile
  if ! isdirectory(expand(&undodir))
    echo "Creating undo dir ".&undodir
    call mkdir( expand(&undodir), 'p', 0700 )
  endif
endif

" }}}

if 1 " use Pathogen? (or tplugin?) {{{1
  if has("user_commands")
    " enable pathogen, which allows for bundles in vim/bundle
    set rtp+=~/.vim/bundle/pathogen
    let g:pathogen_disabled = [ "supertab", "DBGp-Remote-Debugger-Interface" ]
    call pathogen#infect()
  endif
else
"  let g:tplugin#autoload_exclude = ['tplugin']
  set rtp+=~/.vim/bundle/tplugin
  runtime macros/tplugin.vim
  TPlugin tlib
  TPlugin tmru
  TPlugin tcomment
  TPlugin snipmate
  TPlugin autoclose
  TPlugin autocomplpop
  TPlugin unimpaired
  TPlugin surround
  TPlugin swap
  TPlugin easymotion
end

" Settings {{{1
set nocompatible " This must be first, because it changes other options as a side effect.
set encoding=utf8
" Prefer unix fileformat
" set fileformat=unix
set fileformats=unix,dos


" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set confirm " ask for confirmation by default (instead of silently failing)
set splitright splitbelow
set nobackup
set nowritebackup
set history=1000
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

set wrap

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " Set File type to 'text' for files ending in .txt
  autocmd BufNewFile,BufRead *.txt setfiletype text

  " Enable soft-wrapping for text files
  autocmd FileType text,markdown,html,xhtml,eruby,vim setlocal wrap linebreak nolist

  au BufNewFile,BufRead /etc/network/interfaces,/etc/environment setfiletype conf
  au BufRead,BufNewFile *.haml         setfiletype haml
  au BufRead,BufNewFile *.pac          setl filetype=pac

  au FileType mail,markdown,gitcommit setlocal spell

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe 'normal! g`"zv' |
    \ endif

  " Automatically load .vimrc source when saved
  autocmd BufWritePost $MYVIMRC,~/.dotfiles/vimrc,$MYVIMRC.local source $MYVIMRC
  autocmd BufWritePost $MYGVIMRC,~/.dotfiles/gvimrc source $MYGVIMRC
  augroup END

  au BufNewFile,BufRead *pentadactylrc*,*.penta set filetype=pentadactyl.vim

  " if (has("gui_running"))
  "   au FocusLost * stopinsert
  " endif

  if exists(":DetectIndent")
    au! BufRead * if empty('b:no_detect_indent') | DetectIndent | endif
  endif

  " autocommands for fugitive {{{2
  " Source: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
  autocmd User fugitive
    \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)' |
    \   nnoremap <buffer> .. :edit %:h<CR> |
    \ endif
  autocmd BufReadPost fugitive://* set bufhidden=delete

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

  augroup END

  " Whitespace highlighting {{{2
  noremap <silent> <leader>se :let g:MyAuGroupEOLWSactive = (synIDattr(synIDtrans(hlID("EOLWS")), "bg", "cterm") == -1)<cr>
        \:call MyAuGroupEOLWS(mode())<cr>
  let g:MyAuGroupEOLWSactive = 0
  function! MyAuGroupEOLWS(mode)
    if g:MyAuGroupEOLWSactive && &bt == ""
      hi EOLWS ctermbg=red guibg=red
      syn clear EOLWS
      " match whitespace not preceded by a backslash
      if a:mode == "i"
        syn match EOLWS excludenl /[\\]\@<!\s\+\%#\@!$/ containedin=ALL
      else
        syn match EOLWS excludenl /[\\]\@<!\s\+$\| \+\ze\t/ containedin=ALLBUT,gitcommitDiff |
      endif
    else
      syn clear EOLWS
      hi clear EOLWS
    endif
  endfunction
  augroup vimrcExEOLWS
    au!
    highlight EOLWS ctermbg=red guibg=red
    autocmd InsertEnter * call MyAuGroupEOLWS("i")
    " highlight trailing whitespace, space before tab and tab not at the
    " beginning of the line (except in comments), only for normal buffers:
    autocmd InsertLeave,BufWinEnter * call MyAuGroupEOLWS("n")
      " fails with gitcommit: filetype  | syn match EOLWS excludenl /[^\t]\zs\t\+/ containedin=ALLBUT,gitcommitComment

    " add this for Python (via python_highlight_all?!):
    " autocmd FileType python
    "       \ if g:MyAuGroupEOLWSactive |
    "       \ syn match EOLWS excludenl /^\t\+/ containedin=ALL |
    "       \ endif
  augroup END
else
  set autoindent    " always set autoindenting on
endif " has("autocmd")

set tabstop=2
set shiftwidth=2
set expandtab

" Always display the status line
set laststatus=2

" statusline {{{
" old
" set statusline=%t%<%m%r%{fugitive#statusline()}%h%w\ [%{&ff}]\ [%Y]\ [\%03.3b]\ [%04l,%04v][%p%%]\ [%L\ lines\]

if has('statusline')
set statusline=%!MyStatusLine('Enter')
function! FileSize()
  let bytes = getfsize(expand("%:p"))
  if bytes <= 0
    return ""
  endif
  if bytes < 1024
    return bytes
  else
    return (bytes / 1024) . "K"
  endif
endfunction

" Shorten a given filename by truncating path segments.
function! ShortenFilename(bufname, maxlen)
  if getbufvar(bufnr(a:bufname), '&filetype') == 'help'
    return fnamemodify(a:bufname, ':t')
  endif
  if len(a:bufname) <= a:maxlen
    return a:bufname
  endif

  let maxlen_of_parts = 5 " including slash/dot

  let r = a:bufname
  let s:PS = exists('+shellslash') ? (&shellslash ? '/' : '\') : "/"
  let parts = split(a:bufname, '\ze['.escape(s:PS, '\').']')
  let i = len(parts)-1

  let had_ps = 0
  while i>0
    if len(r) <= a:maxlen
      return r
    endif
    let i -= 1
    if len(parts[i]) > maxlen_of_parts
      " Let's see if there are dots or hyphens to truncate at, e.g.
      " 'vim-pkg-debian' => 'v-p-d…'
      let w = split(parts[i], '\ze[._-]')
      if len(w) > 1
        let w = map(w, 'v:val[0:1]')
        let parts[i] = join(w, '').'…' " indicate that this has been truncated
      else
        let parts[i] = parts[i][0:maxlen_of_parts-2].'…'
      endif
    endif
    let r = join(parts, '')
  endwhile
  return r
endfunction


" colorize start of statusline according to file status,
" source: http://www.reddit.com/r/vim/comments/gexi6/a_smarter_statusline_code_in_comments/c1n2oo5
hi StatColor guibg=#95e454 guifg=black ctermbg=lightgreen ctermfg=black
hi Modified guibg=orange guifg=black ctermbg=lightred ctermfg=black
function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    hi StatColor guibg=orange ctermbg=lightred
  elseif a:mode == 'r'
    hi StatColor guibg=#e454ba ctermbg=magenta
  elseif a:mode == 'v'
    hi StatColor guibg=#e454ba ctermbg=magenta
  else
    hi StatColor guibg=red ctermbg=red
  endif
endfunction
augroup MyStatusLine
  au!
  au WinEnter * setlocal statusline=%!MyStatusLine('Enter')
  au WinLeave * setlocal statusline=%!MyStatusLine('Leave')
  au InsertEnter * call InsertStatuslineColor(v:insertmode)
  au InsertLeave * hi StatColor guibg=#95e454 guifg=black ctermbg=lightgreen ctermfg=black
  au InsertLeave * hi Modified guibg=orange guifg=black ctermbg=lightred ctermfg=black
augroup END

fun! MyStatusLine(mode)
  let r = []
  if a:mode == 'Enter'
    let r += ["%#StatColor#"]
  endif
  let r += ['[%n@%{winnr()}] ']  " buffer and windows nr
  let r += ['%{ShortenFilename(fnamemodify(bufname("%"), ":~"), 20)}']
  if a:mode == 'Enter'
    let r += ["%*"]
  endif

  " syntax errors
  if exists('*SyntasticStatuslineFlag')
    let r+=['%#WarningMsg#']
    let r+=['%{SyntasticStatuslineFlag()}']
    let r+=['%*']
  endif

  " modified flag
  let r += ["%#Modified#"]
  let r += ["%{getbufvar(bufnr('%'), '&modified') ? ' [+]' : '' }"]
  if a:mode == 'Leave' | let r += ["%*"] | endif

  " readonly flag
  let r += ["%{getbufvar(bufnr('%'), '&readonly') && getbufvar(bufnr('%'), '&ft') != 'help' ? '[RO]' : '' }"]
  if a:mode == 'Enter' | let r += ["%*"] | endif

  let r += ['%<']       "cut here
  let r += ['%( [']
  let r += ['%Y']      "filetype
  " let r += ['%H']      "help file flag
  let r += ['%W']      "preview window flag
  " let r += ['%R']      "read only flag
  let r += ['%{&ff=="unix"?"":",".&ff}']  "file format (if !=unix)
  let r += ['%{strlen(&fenc) && &fenc!="utf-8"?",".&fenc:""}'] "file encoding (if !=utf-8)
  let r += ['] %)']
  if exists("*fugitive#statusline") " might not exist, e.g.  when :redrawing during startup (eclim debug)
    let r += ['%{fugitive#statusline()}']
  endif

  let r += ['%=']      "left/right separator
  " let r += ['%b,0x%-8B '] " Current character in decimal and hex representation
  let r += [' %{FileSize()} ']  " size of file (human readable)
  let r += ['%-12(%l,%c%V%)'] " Current line and column
  " let r += ['%l/%L']   "cursor line/total lines
  let r += [' %P']    "percent through file
  return join(r, '')
endfunction
endif
"}}}


" Hide search highlighting
if has('extra_search')
  nnoremap <silent> <Leader>h :set hlsearch!<CR>:set hlsearch?<CR>
  nnoremap <silent> <C-l> :nohlsearch<CR><C-l>
endif

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>ee :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>t
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
" cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Change to current file's dir
nmap <Leader>cd :lcd <C-R>=expand('%:p:h')<CR><CR>

" Duplicate a selection
" Visual mode: D
vmap D y'>p

" Press Shift+P while in visual mode to replace the selection without
" overwriting the default register
vmap P p :call setreg('"', getreg('0')) <CR>

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

imap <C-L> <Space>=><Space>

" Display extra whitespace
set list listchars=tab:»·,trail:·,eol:¬,nbsp:_,extends:»,precedes:«
set fillchars=fold:-
" set showbreak=↪ " no required with line numbers
nnoremap <silent> <leader>sl :set list!<CR>
inoremap <silent> <leader>sl <C-o>:set list!<CR>
set nolist

" toggle settings, mnemonic "set paste", "set wrap", ..
set pastetoggle=<leader>sp
noremap <leader>sw :set wrap!<cr>
noremap <leader>ss :set spell!<cr>
nmap    <leader>sc <Plug>Colorizer


" Use Ack instead of Grep when available
" if executable("ack")
"   set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
" elseif executable("ack-grep")
"   set grepprg=ack-grep\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
" else
   " this is for Windows/cygwin and to add -H
   set grepprg=grep\ -nH\ $*\ /dev/null
" endif

" Line numbers"{{{
au BufReadPost *
      \ if &bt == "quickfix" || ! exists('+relativenumber') |
      \   set number |
      \ else |
      \   set relativenumber |
      \ endif |
      \ call SetNumberWidth()
function! ToggleLineNr()
  " relativenumber => number => nonumber/norelativenumber
  if exists('+relativenumber')
    if &relativenumber | set number | elseif &number | set nonumber | else | set relativenumber | endif
  else
    set number!
  endif
  call SetNumberWidth()
endfunction
function! SetNumberWidth()
  if &number
    if has('float')
      let &l:numberwidth = float2nr(ceil(log10(line('$'))))
    endif
  elseif exists('+relativenumber') && &relativenumber
    set numberwidth=2
  endif
endfun
nmap <leader>sa :call ToggleLineNr()<CR>"}}}

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
set completeopt=longest,menu
set wildmode=list:longest,list:full
" set complete+=kspell " complete from spell checking
" set dictionary+=spell " very useful (via C-X C-K), but requires ':set spell' once
if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
    \   if &omnifunc == "" |
    \     setlocal omnifunc=syntaxcomplete#Complete |
    \   endif
endif


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

" Make the current status line stand out, e.g. with xoria256 (using the
" PreProc colors from there)
" hi StatusLine      ctermfg=150 guifg=#afdf87

" via http://www.reddit.com/r/programming/comments/7yk4i/vim_settings_per_directory/c07rk9d
" :au! BufRead,BufNewFile *path/to/project/*.* setlocal noet

set hidden

" consider existing windows (but not tabs) when opening files, e.g. from quickfix
set switchbuf=useopen

" Maps for jj and kj to act as Esc (kj is idempotent in normal mode)
ino jj <esc>
cno jj <c-c>
" ino kj <esc>
" cno kj <c-c>

" close tags (useful for html)
imap <Leader>/ </<C-X><C-O>

" paste shortcut (source: http://userobsessed.net/tips-and-tricks/2011/05/10/copy-and-paste-in-vim/)
imap <Leader>v  <C-O>:set paste<CR><C-r>*<C-O>:set nopaste<CR>
imap <Leader><Leader>v  <C-O>:set paste<CR><C-r>+<C-O>:set nopaste<CR>


" swap previously selected text with currently selected one (via http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines#Visual-mode_swapping)
vnoremap <C-X> <Esc>`.``gvP``P

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Sudo write
if executable('sudo') && executable('tee')
  command! SUwrite
        \ execute 'w !sudo tee % > /dev/null' |
        \ setlocal nomodified
endif


" Easy indentation in visual mode
" This keeps the visual selection active after indenting.
" Usually the visual selection is lost after you indent it.
"vmap > >gv
"vmap < <gv

" Make `gp` select the last pasted text
" (http://vim.wikia.com/wiki/Selecting_your_pasted_text).
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Syntax Checking entire file (Python)
" Usage: :make (check file)
" :clist (view list of errors)
" :cn, :cp (move around list of errors)
" NOTE: should be provided by checksyntax plugin
" autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
" autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

if 1 " has('eval') {{{1
" Strip trailing whitespace {{{2
function! StripWhitespace () range
    let old_query = getreg('/')
    exe 'keepjumps '.a:firstline.','.a:lastline.'substitute/[\\]\@<!\s\+$//e'
    call setreg('/', old_query)
endfunction
command! -range=% UnTrail
      \ keepjumps <line1>,<line2>call StripWhitespace()
noremap <leader>st :UnTrail<CR>

" Toggle semicolon at end of line {{{2
function! MyToggleSemicolon()
  let ss = @/ | let save_cursor = getpos(".")
  try
    s/\([^;]\)$/\1;/
	catch /^Vim\%((\a\+)\)\=:E486: Pattern not found/
    s/;$//
  finally
    let @/ = ss | call setpos('.', save_cursor)
  endtry
endfunction
noremap <Leader>; :call MyToggleSemicolon()<cr>

noremap ö :

" Grep in the current (potential unsaved) buffer {{{2
command! -nargs=1 GrepCurrentBuffer call GrepCurrentBuffer('<args>')
fun! GrepCurrentBuffer(q)
	let save_cursor = getpos(".")
  let save_errorformat = &errorformat
  try
    set errorformat=%f:%l:%m
    cexpr []
    exe 'g/'.escape(a:q, '/').'/caddexpr expand("%") . ":" . line(".") .  ":" . getline(".")'
    cw
  finally
    call setpos('.', save_cursor)
    let &errorformat = save_errorformat
  endtry
endfunction
noremap <leader>. :GrepCurrentBuffer <C-r><C-w><cr>


" Commands to disable (and re-enable) all other tests in the current file. {{{2
command! DisableOtherTests call DisableOtherTests()
fun! DisableOtherTests()
  let save_cursor = getpos(".")
  try
    %s/function test_/function ttest_/
    call setpos('.', save_cursor)
    call search('function ttest_', 'b')
    normal wx
  finally
    call setpos('.', save_cursor)
  endtry
endfun
command! EnableAllTests call EnableAllTests()
fun! EnableAllTests()
  let save_cursor = getpos(".")
  try
    %s/function ttest_/function test_/
  finally
    call setpos('.', save_cursor)
  endtry
endfun


" Twiddle case of chars / visual selection {{{2
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


" Close the last window on entering if its buffer is a controlling
" buffer (NERDTree, quickfix). {{{2
function! s:CloseIfOnlyControlWinLeft()
  if winnr("$") != 1
    return
  endif
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
        \ || getbufvar(winbufnr(1), '&buftype') == 'quickfix'
    q
  endif
endfunction
autocmd WinEnter * call s:CloseIfOnlyControlWinLeft()


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

" Open Windows explorer and select current file
if executable('explorer.exe')
  command! Winexplorer :!start explorer.exe /e,/select,"%:p:gs?/?\\?"
endif

" do not pick last item automatically (non-global: g:tmru_world.tlib_pick_last_item)
let g:tlib_pick_last_item = 1
let g:tlib_inputlist_match = 'cnf'
let g:tmruSize = 500

" Easytags
let g:easytags_on_cursorhold = 0 " disturbing, at least on work machine
let g:easytags_cmd = 'ctags'
let g:easytags_suppress_ctags_warning = 1
let g:easytags_dynamic_files = 1
let g:easytags_resolve_links = 1

let g:detectindent_preferred_indent = 2 " used for sw and ts if only tabs

" command-t plugin
let g:CommandTMaxFiles=50000
let g:CommandTMaxHeight=20
if has("autocmd") && exists(":CommandTFlush") && has("ruby")
  " this is required for Command-T to pickup the setting(s)
  au VimEnter * CommandTFlush
endif
if (has("gui_running"))
  " use Alt-T in GUI mode
  map <M-t> :CommandT<CR>
endif
map <leader>tt :CommandT<CR>
map <leader>t. :execute "CommandT ".expand("%:p:h")<cr>
map <leader>t  :CommandT<space>
map <leader>tb :CommandTBuffer<CR>

" supertab
let g:SuperTabLongestEnhanced=1
let g:SuperTabLongestHighlight=1 " triggers bug with single match (https://github.com/ervandew/supertab/commit/e026bebf1b7113319fc7831bc72d0fb6e49bd087#commitcomment-297471)

let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

let g:LustyExplorerSuppressRubyWarning = 1 " suppress warning when vim-ruby is not installed

" use for encryption:
" openssl enc -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd > 1
" openssl enc -d -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd < 1
let g:pastebin_api_dev_key = '95d8fa0dd25e7f8b924dd8103af42218'
let g:EasyMotion_keys = 'asdfghjklöä' " home row

let g:EclimLargeFileEnabled = 0
" let g:EclimLogLevel = 6
" if exists(":EclimEnable")
"   au VimEnter * EclimEnable
" endif

" Prepend <leader> to visualctrlg mappings.
let g:visualctrg_no_default_keymappings = 1
silent! vmap <unique> <Leader><C-g>  <Plug>(visualctrlg-briefly)
silent! vmap <unique> <Leader>g<C-g> <Plug>(visualctrlg-verbosely)

" Toggle quickfix window, using Q. {{{2
" Based on: http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
nnoremap Q :QFix<CR>
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("t:qfix_buf") && bufwinnr(t:qfix_buf) != -1 && a:forced == 0
    cclose
  else
    cwindow 10 " 10 is height
    let t:qfix_buf = bufnr("%")
  endif
endfunction
" used to track manual opening of the quickfix, e.g. via `:copen`
augroup QFixToggle
  autocmd!
  autocmd BufWinEnter quickfix let g:qfix_buf = bufnr("%")
augroup END

" 2}}}
endif " 1}}} eval guard

" Mappings {{{1
" Map cursor keys in normal mode to navigate windows/tabs
" via http://www.reddit.com/r/vim/comments/flidz/partial_completion_with_arrows_off/c1gx8it
" nnoremap  <Down> <C-W>j
" nnoremap  <Up> <C-W>k
" nnoremap  <Right> <C-W>l
" nnoremap  <Left> <C-W>h

" does not work with gnome-terminal
nnoremap <C-s> :up<CR>
inoremap <C-s> <Esc>:up<CR>

" defined in php-doc.vim
" nnoremap <Leader>d :call PhpDocSingle()<CR>

noremap <Leader>n :NERDTree<space>
noremap <Leader>n. :execute "NERDTree ".expand("%:p:h")<cr>
noremap <Leader>nb :NERDTreeFromBookmark<space>
noremap <Leader>nn :NERDTreeToggle<cr>
noremap <Leader>no :NERDTreeToggle<space>
noremap <Leader>nf :NERDTreeFind<cr>
noremap <Leader>nc :NERDTreeClose<cr>
noremap <F1> :tab<Space>:help<Space>
" ':tag {ident}' - difficult on german keyboard layout and not working in gvim/win32
noremap <F2> <C-]>
" expand abbr
imap <F2> <C-]>
noremap <F3> :if exists('g:tmru_world')<cr>:let g:tmru_world.restore_from_cache = ['filter']<cr>:endif<cr>:TRecentlyUsedFiles<cr>'
noremap <S-F3> :if exists('g:tmru_world')<cr>:let g:tmru_world.restore_from_cache = []<cr>:endif<cr>:TRecentlyUsedFiles<cr>
noremap <F5> :GundoToggle<cr>
noremap <F11> :YRShow<cr>


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

" gets ignored by tmru
set suffixes+=.tmp

" Smart way to move btw. windows {{{2
" (use cursor keys to not overwrite C-l (redraw))
map <C-Down> <C-W>j
map <C-Up> <C-W>k
map <C-Left> <C-W>h
map <C-Right> <C-W>l

noremap <Up> gk
noremap <Down> gj

" Make C-BS and C-Del work like they do in most text editors for the sake of muscle memory {{{2
imap <C-BS> <C-W>
imap <C-Del> <C-O>dw
imap <C-S-Del> <C-O>dW
nmap <C-Del> dw
nmap <C-S-Del> dWa

" Map delete to 'delete to black hole register' (experimental, might use
" `d` instead)
map  <Del> "_x
imap <Del> <C-O>"_x
vmap <Del> "_x

map _  <Plug>(operator-replace)

" edit vimrc shortcut
nnoremap <leader>ev <C-w><C-s><C-l>:exec "e ".resolve($MYVIMRC)<cr>
" edit zshrc shortcut
nnoremap <leader>ez <C-w><C-s><C-l>:exec "e ".resolve("~/.zshrc")<cr>

" Utility functions to create file commands
" Source: https://github.com/carlhuda/janus/blob/master/gvimrc
" function! s:CommandCabbr(abbreviation, expansion)
"   execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
" endfunction

set formatoptions+=l " do not wrap lines that have been longer when starting insert mode already
set guioptions-=m

set viminfo+=% " remember opened files and restore on no-args start (poor man's crash recovery)

" I feel dirty, plz rename kthxbye!
behave mswin
set keymodel-=stopsel " do not stop visual selection with cursor keys
set selection=inclusive
set clipboard=unnamed
set mouse=a

" Open URL
nmap <leader>gw <Plug>(openbrowser-smart-search)
vmap <leader>gw <Plug>(openbrowser-smart-search)

" remap CTRL-W_ using maximize.vim (smarter and toggles)
map <c-w>_ :MaximizeWindow<cr>

" Exit with ÄÄ (German keyboard layout)
noremap ÄÄ :confirm qall<cr>
inoremap ÄÄ <C-O>:confirm qall<cr>
cnoremap ÄÄ <C-C>:confirm qall<cr>
onoremap ÄÄ <C-C>:confirm qall<cr>
noremap ää :confirm q<cr>

" vimdiff current vs git head (fugitive extension) {{{2
nnoremap <Leader>gd :Gdiff<cr>
" Close any corresponding diff buffer
function! MyCloseDiff()
  if (&diff == 0 || getbufvar('#', '&diff') == 0)
        \ && (bufname('%') !~ '^fugitive:' && bufname('#') !~ '^fugitive:')
    echom "Not in diff view."
    return
  endif

  " close current buffer if alternate is not fugitive but current one is
  if bufname('#') !~ '^fugitive:' && bufname('%') =~ '^fugitive:'
    if bufwinnr("#") == -1
      b #
      bd #
    else
      bd
    endif
  else
    bd #
  endif
endfunction
nnoremap <Leader>gD :call MyCloseDiff()<cr>

" Toggle highlighting of too long lines {{{2
function! ToggleTooLongHL()
  if exists('*matchadd')
    if ! exists("w:TooLongMatchNr")
      let last = (&tw <= 0 ? 80 : &tw)
      let w:TooLongMatchNr = matchadd('ErrorMsg', '.\%>' . (last+1) . 'v', 0)
      echo " Long Line Highlight"
    else
      call matchdelete(w:TooLongMatchNr)
      unlet w:TooLongMatchNr
      echo "No Long Line Highlight"
    endif
  endif
endfunction
" noremap <silent> <leader>sl :call ToggleTooLongHL()<cr>

" Swap ' and ` keys (` is much more useful) {{{2
noremap ' `
sunmap '
noremap ` '
sunmap `
noremap g' g`
sunmap g'
noremap g` g'
sunmap g`

" make Y like D & C {{{2
nnoremap Y y$
xnoremap Y y$

" Idea: change the xterm cursor color for insert mode {{{2
if &term =~? '^xterm' && exists('&t_SI') && &t_Co > 1
  " let &t_SI="\<Esc>]12;purple\x7"
  " let &t_EI="\<Esc>]12;green\x7"
endif

" Folding {{{2
if has("folding")
  set foldenable
  set foldmethod=marker
  " set foldlevel=1
  " set foldnestmax=2
  " set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '
endif

if has('eval')
  for k in ['i', 'm', 'M', 'n', 'N', 'r', 'R', 'v', 'x', 'X']
    execute "nnoremap <silent> Z".k." :windo normal z".k."<CR>"
  endfor
endif

if has('user_commands')
  " typos
  command! Q q
  command! W w
  command! Wq wq
  command! Wqa wqa
endif

"{{{2 Abbreviations
" <C-g>u adds break to undo chain, see i_CTRL-G_u
iabbr sg Sehr geehrte Damen und Herren,<cr>
iabbr mfg Mit freundlichen Grüßen,<cr><C-g>u<C-r>=g:my_full_name<cr>
iabbr sig -- <cr><C-r>=readfile(expand('~/.mail-signature'))
iabbr ... …
"}}}

" Local config (if any)
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" vim: fdm=marker
