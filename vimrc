" PROFILE
" exec 'profile start /tmp/vim.'.getpid().'.profile.txt'
" profile! file **

" Settings {{{1
set nocompatible " This must be first, because it changes other options as a side effect.
set hidden
set encoding=utf8
" Prefer unix fileformat
" set fileformat=unix
set fileformats=unix,dos

set backspace=indent,eol,start " allow backspacing over everything in insert mode
set confirm " ask for confirmation by default (instead of silently failing)
set nosplitright splitbelow
set diffopt+=vertical
set history=1000
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching

set backup          " enable backup (default off)
set writebackup     " keep a backup while writing the file (default on)
set backupcopy=yes  " important to keep the file descriptor (inotify)

set nowrap

set autoindent    " always set autoindenting on (fallback after 'indentexpr')

" set colorcolumn=78

set tabstop=2
set shiftwidth=2
set noshiftround  " for `>`/`<` not behaving like i_CTRL-T/-D
set expandtab
set iskeyword+=-
set isfname-==    " remove '=' from filename characters; for completion of FOO=/path/to/file

set laststatus=2  " Always display the statusline
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)

" use short timeout after Escape sequence in terminal mode (for keycodes)
set ttimeoutlen=10

" Format options {{{2
set formatoptions+=r " Insert comment leader after hitting <Enter>
set formatoptions+=o " Insert comment leader after hitting o or O in normal mode
set formatoptions+=t " Auto-wrap text using textwidth
set formatoptions+=c " Autowrap comments using textwidth
" set formatoptions+=b " Do not wrap if you modify a line after textwidth; handled by 'l' already?!
set formatoptions+=l " do not wrap lines that have been longer when starting insert mode already
set formatoptions+=q " Allow formatting of comments with "gq".
set formatoptions+=t " Auto-wrap text using textwidth
set formatoptions+=n " Recognize numbered lists
if v:version > 703 || v:version == 703 && has("patch541")
" Delete comment character when joining commented lines
  set formatoptions+=j
endif
" }}}

set synmaxcol=1000  " don't syntax-highlight long lines (default: 3000)

set guioptions-=m  " no menu with gvim

set viminfo+=% " remember opened files and restore on no-args start (poor man's crash recovery)
set viminfo+=! " keep global uppercase variables. Used by localvimrc.

set selectmode=
set mousemodel=popup " extend/popup/pupup_setpos
set keymodel-=stopsel " do not stop visual selection with cursor keys
set selection=inclusive
" set clipboard=unnamed
" do not mess with X selection by default
set clipboard=

if has('mouse')
  set mouse=a " Enable mouse
endif
set ttymouse=xterm2  " Make mouse work with Vim in tmux

set showmatch  " show matching pairs
set matchtime=3
" Jump to matching bracket when typing the closing one.
" Deactivated, causes keys to be ignored when typed too fast (?).
"inoremap } }<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ] ]<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ) )<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a

set sessionoptions+=unix,slash " for unix/windows compatibility
set nostartofline " do not go to start of line automatically when moving
set scrolloff=3 " scroll offset/margin (cursor at 4th line)
augroup set_scrollof
  au!
  " Especially with quickfix (mouse jumping, narrow)
  au BufEnter * if &buftype != "" | set scrolloff=0 | end
augroup END
set sidescroll=1
set sidescrolloff=10
set commentstring=#\ %s

" 'suffixes' get ignored by tmru
set suffixes+=.tmp
set suffixes+=.pyc
" set suffixes+=.sw?

" case only matters with mixed case expressions
set ignorecase smartcase
set smarttab

set lazyredraw  " No redraws in macros.

set wildmenu
" move cursor instead of selecting entries (wildmenu)
cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>

" consider existing windows (but not tabs) when opening files, e.g. from quickfix
" set switchbuf=useopen
" set switchbuf=split

" Display extra whitespace
" set list listchars=tab:»·,trail:·,eol:¬,nbsp:_,extends:❯,precedes:❮
" set fillchars=stl:^,stlnc:-,vert:\|,fold:-,diff:-
" set fillchars=vert:\|,fold:·,stl:\ ,stlnc:━,diff:⣿
set fillchars=vert:\ ,fold:\ ,stl:\ ,stlnc:\ ,diff:⣿

" Do not display "Pattern not found" messages during YouCompleteMe completion.
" Patch: https://groups.google.com/forum/#!topic/vim_dev/WeBBjkXE8H8
if 1 && exists(':try')
  try
    set shortmess+=c
  catch /E539: Illegal character/
  endtry
endif

set nolist
set listchars=tab:»·,trail:·,eol:¬,nbsp:_,extends:»,precedes:«
" Experimental: setup listchars diffenrently for insert mode {{{
" fun! MySetupList(mode)
"   if a:mode == 'i'
"     let b:has_list=&list
"     if ! &list
"       " set listchars-=eol:¬
"     endif
"     set list
"   else
"     if !(exists('b:has_list') && b:has_list)
"       set nolist
"     endif
"     " set listchars+=eol:¬
"   endif
" endfun
" augroup trailing
"   au!
"   au InsertEnter * call MySetupList('i')
"   au InsertLeave * call MySetupList('n')
" augroup END
" }}}

" Generic GUI options. {{{2
if has('gui_running')
  set guioptions-=T " hide toolbar
  if has('vim_starting')
    " TODO: dependent on monitor size.
    set lines=50 columns=90
  endif
  set guifont=Ubuntu\ Mono\ For\ Powerline\ 12,DejaVu\ Sans\ Mono\ 10
endif
" }}}1

if 1 " has('eval') / `let` may not be available.
  " Use NeoComplCache, if YouCompleteMe is not available (needs compilation). {{{
  let s:has_ycm = len(glob('~/.vim/bundle/YouCompleteMe/python/ycm_core.*'))
  let s:use_ycm = s:has_ycm
  " let s:use_ycm = 0
  let s:use_neocomplcache = ! s:use_ycm
  " }}}

  " Use both , and Space as leader.
  let mapleader = ","
  " Not for imap!
  nmap <space> <Leader>
  vmap <space> <Leader>

  " Map `s` (occupied by vim-sneak).
  " TODO: this needs improvement
  nnoremap <Leader>ss s
  xnoremap <Leader>ss s

  let g:my_full_name = "Daniel Hahler"

  let g:snips_author = g:my_full_name

  " TAB is used by YouCompleteMe/SuperTab
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsJumpForwardTrigger="<c-j>"
  let g:UltiSnipsJumpBackwardTrigger="<c-k>"
  let g:UltiSnipsListSnippets = "<c-b>"
  let g:UltiSnipsEditSplit='vsplit'

  " let g:UltiSnips.always_use_first_snippet = 1
  augroup UltiSnipsConfig
    au!
    au FileType smarty UltiSnipsAddFiletypes smarty.html.javascript.php
    au FileType html   UltiSnipsAddFiletypes html.javascript.php
  augroup END

  if !exists('g:UltiSnips') | let g:UltiSnips = {} | endif
  let g:UltiSnips.load_early = 1
  let g:UltiSnips.UltiSnips_ft_filter = {
        \ 'default' : {'filetypes': ["FILETYPE", "all"] },
        \ 'html'    : {'filetypes': ["html", "javascript", "all"] },
        \ 'python'  : {'filetypes': ["python", "django", "all"] },
        \ 'htmldjango'  : {'filetypes': ["python", "django", "html", "all"] },
        \ }
  let g:UltiSnips.snipmate_ft_filter = {
        \ 'default' : {'filetypes': ["FILETYPE", "_"] },
        \ 'html'    : {'filetypes': ["html", "javascript", "_"] },
        \ 'python'  : {'filetypes': ["python", "django", "_"] },
        \ 'htmldjango'  : {'filetypes': ["python", "django", "html", "_"] },
        \ }
     "\ 'html'  : {'filetypes': ["html", "javascript"], 'dir-regex': '[._]vim$' },


  if has('win32') || has('win64')
    " replace ~/vimfiles with ~/.vim in runtimepath
    " let &runtimepath = join( map( split(&rtp, ','), 'substitute(v:val, escape(expand("~/vimfiles"), "\\"), escape(expand("~/.vim"), "\\"), "g")' ), "," )
    let &runtimepath = substitute(&runtimepath, '\('.escape($HOME, '\').'\)vimfiles\>', '\1.vim', 'g')
  endif

  " let g:sparkupExecuteMapping = '<Leader>e'
  " let g:sparkupNextMapping = '<Leader>ee'
  "
  " obsolete: using vim-sneak instead.
  " let g:EasyMotion_leader_key = '<Leader>m'
  " let g:EasyMotion_keys = 'asdfghjklöä' " home row

  " autocomplpop: do not complete from dictionary; -= "k"
  " (manually trigger it by C-X C-K instead).
  let g:acp_completeOption = '.,w,b'

  " Syntastic {{{
  let g:syntastic_enable_signs=1
  let g:syntastic_auto_jump=2
  let g:syntastic_check_on_wq=1  " Only for active filetypes.
  let g:syntastic_auto_loc_list=1
  " let g:syntastic_always_populate_loc_list=1  " Default: 0
  " let g:syntastic_echo_current_error=0 " TEST: faster?!
  let g:syntastic_mode_map = {
        \'mode': 'passive',
        \ 'active_filetypes': ['ruby', 'php', 'lua'],
        \ 'passive_filetypes': ['puppet'] }
  let g:syntastic_error_symbol='✗'
  let g:syntastic_warning_symbol='⚠'
  let g:syntastic_aggregate_errors = 0
  " let g:syntastic_python_python_exe = 'python3'
  " let g:syntastic_python_checkers = ['pyflakes', 'flake8', 'pep8', 'pylint', 'python']
  " let g:syntastic_python_checkers = ['python', 'pep8']
  let g:syntastic_python_checkers = ['python', 'flake8']
  " let g:syntastic_php_checkers = ['php']
  let g:syntastic_loc_list_height = 1 " handled via qf autocommand: AdjustWindowHeight

  " See 'syntastic_quiet_messages' and 'syntastic_<filetype>_<checker>_quiet_messages'
  " let g:syntastic_quiet_messages = {
  "       \ "level": "warnings",
  "       \ "type":  "style",
  "       \ "regex": '\m\[C03\d\d\]',
  "       \ "file":  ['\m^/usr/include/', '\m\c\.h$'] }
  let g:syntastic_quiet_messages = { "level": [],
        \ 'type': ['style'] }

  fun! SyntasticToggleQuiet(k, v)
    let idx = index(g:syntastic_quiet_messages[a:k], a:v)
    if idx == -1
      call add(g:syntastic_quiet_messages[a:k], a:v)
      echom 'Syntastic: '.a:k.':'.a:v.' disabled (filtered).'
    else
      call remove(g:syntastic_quiet_messages[a:k], idx)
      echom 'Syntastic: '.a:k.':'.a:v.' enabled (not filtered).'
    endif
  endfun
  command! SyntasticToggleWarnings call SyntasticToggleQuiet('level', 'warnings')
  command! SyntasticToggleStyle    call SyntasticToggleQuiet('type', 'style')
  nmap <Leader>se :SyntasticToggleMode<cr>


  " gist-vim {{{
  let g:gist_detect_filetype = 1
  " }}}

  " tinykeymap: used to move between signs from quickfixsigns and useful by itself. {{{2
  let g:tinykeymap#mapleader = '<Leader>k'
  let g:tinykeymap#timeout = 0  " default: 5000s (ms)
  let g:tinykeymap#conflict = 1
  " Exit also with 'q'.
  let g:tinykeymap#break_key = 113
  " }}}

  " Call bcompare with current and alternate file.
  command! BC call system('bcompare '.shellescape(expand('%')).' '.shellescape(expand('#')).'&')

  if s:use_neocomplcache
  " neocomplcache {{{
    let g:neocomplcache_cursor_hold_i_time = 300 " default
    let g:neocomplcache_enable_at_startup = 1
    let g:neocomplcache_enable_camel_case_completion = 1
    let g:neocomplcache_enable_cursor_hold_i = 1
    " let g:neocomplcache_enable_debug = 1
    let g:neocomplcache_enable_ignore_case = 0
    let g:neocomplcache_enable_smart_case = 1
    let g:neocomplcache_enable_underbar_completion = 1
    let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
    let g:neocomplcache_min_syntax_length = 3

    " Define dictionary.
    " let g:neocomplcache_dictionary_filetype_lists = {
    "     \ 'default' : '',
    "     \ 'vimshell' : $HOME.'/.vimshell_hist',
    "     \ 'scheme' : $HOME.'/.gosh_completions'
    "     \ }

    " Plugin key-mappings.
    " imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    " smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    " inoremap <expr><C-g>     neocomplcache#undo_completion()
    " inoremap <expr><C-l>     neocomplcache#complete_common_string()

    " if exists(':<Plug>DiscretionaryEnd') " needs to come after pathogen
      function! s:my_cr_function()
        return pumvisible() ? neocomplcache#close_popup() : "\<CR>\<Plug>DiscretionaryEnd"
      endfunction
    " else
      " function! s:my_cr_function()
      "   return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
      " endfunction
    " endif
    " imap <expr><silent> <CR> <SID>my_cr_function()

    " inoremap <CR> <C-R>=neocomplcache#smart_close_popup()<CR>

    " inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    " interferes with i_CTRL-Y (copy char above)
    " inoremap <expr><C-y>  neocomplcache#close_popup()
    " used by sparkup / not necessary:
    " inoremap <expr><C-e>  neocomplcache#cancel_popup()

    " let g:neocomplcache_enable_insert_char_pre=1

    " auto-select first entry
    let g:neocomplcache_enable_auto_select = 1

    " Force overwriting completefunc set by eclim
    let g:neocomplcache_force_overwrite_completefunc = 1
    " XXX: exists() does not work with autoload function
    augroup neocomplcachefiletype
    au!
    " au FileType * let f='eclim#'.&filetype.'#complete#CodeComplete' | if exists('*'.f) | exec('setlocal omnifunc='.f) | endif

    " Enable omni completion.
    au FileType css setlocal omnifunc=csscomplete#CompleteCSS
    au FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    au FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    au FileType python setlocal omnifunc=pythoncomplete#Complete
    au FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    "au FileType ruby setlocal omnifunc=rubycomplete#Complete
    augroup END

    " Enable heavy omni completion.
    if !exists('g:neocomplcache_omni_patterns')
      let g:neocomplcache_omni_patterns = {}
    endif
    let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
    let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
    let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
  endif " }}}

  " YouCompleteMe {{{
  let g:ycm_filetype_blacklist = {
    \ 'ycmblacklisted': 1
    \}
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_collect_identifiers_from_comments_and_strings = 1
  let g:ycm_extra_conf_globlist = ['~/src/awesome/.ycm_extra_conf.py']

  " Deactivated: causes huge RAM usage (YCM issue 595)
  " let g:ycm_collect_identifiers_from_tags_files = 1

  " EXPERIMENTAL: auto-popups and experimenting with SuperTab
  " NOTE: this skips the following map setup (also for C-n):
  "       ' pumvisible() ? "\<C-p>" : "\' . key .'"'
  " let g:ycm_key_list_select_completion = []
  " let g:ycm_key_list_previous_completion = []

  " " disable trigger for 'php' (slow; trigger it manually)
  " let g:ycm_semantic_triggers =  {
  "   \   'c' : ['->', '.'],
  "   \   'objc' : ['->', '.'],
  "   \   'cpp,objcpp' : ['->', '.', '::'],
  "   \   'perl' : ['->'],
  "   \   'php' : [],
  "   \   'cs,java,javascript,d,vim,ruby,python,perl6,scala,vb,elixir' : ['.'],
  "   \   'lua' : ['.', ':'],
  "   \   'erlang' : [':'],
  "   \ }
  " }}}

  " Tags (configure this before easytags, except when using easytags_dynamic_files)
  " Look for tags file in parent directories, upto "/"
  set tags=./tags;/

  " CR and BS mapping: call various plugins manually. {{{
  let g:endwise_no_mappings = 1  " NOTE: must be unset instead of 0
  let g:cursorcross_no_map_CR = 1
  let g:cursorcross_no_map_BS = 1
  let g:delimitMate_expand_cr = 0
  let g:SuperTabCrMapping = 0  " Skip SuperTab CR map setup (skipped anyway for expr mapping)
  let g:cursorcross_mappings = 0

  " Force delimitMate mapping (gets skipped if mapped already).
  fun! My_CR_map()
    " "<CR>" via delimitMateCR
    return "\<Plug>delimitMateCR\<Plug>CursorCrossCR\<Plug>DiscretionaryEnd"
  endfun
  imap <expr> <CR> My_CR_map()

  fun! My_BS_map()
    " "<BS>" via delimitMateBS
    return "\<Plug>delimitMateBS\<Plug>CursorCrossCR"
  endfun
  imap <expr> <BS> My_BS_map()

  " For endwise.
  imap <C-X><CR> <CR><Plug>AlwaysEnd
  " }}}

  " inoremap <expr> <tab>  pumvisible() ? "\<C-n>" : "\<tab>"

  " Add tags from $VIRTUAL_ENV
  if $VIRTUAL_ENV != ""
    let &tags = $VIRTUAL_ENV.'/tags,' . &tags
  endif

  " syntax mode setup
  let php_sql_query = 1
  let php_htmlInStrings = 1
  " let php_special_functions = 0
  " let php_alt_comparisons = 0
  " let php_alt_assignByReference = 0
  " let PHP_outdentphpescape = 1
  let g:PHP_autoformatcomment = 0 " do not set formatoptions/comments automatically
  let g:php_noShortTags = 1

  " always use Smarty comments in smarty files
  " NOTE: for {php} it's useful
  " let g:tcommentGuessFileType_smarty = 0

  " -- adopted from indent/php.vim:
  " Set the comment setting to something correct for PHP
  au FileType php setlocal comments=s1:/*,mb:*,ex:*/,://,:#
endif

if &t_Co == 8
  " Allow color schemes to do bright colors without forcing bold. (vim-sensible)
  if $TERM !~# '^linux'
    set t_Co=16
  endif
  " Fix t_Co: hack to enable 256 colors with e.g. "screen-bce" on CentOS 5.4;
  " COLORTERM=lilyterm used for LilyTerm (set TERM=xterm).
  " Do not match "screen" in Linux VT
  " if (&term[0:6] == "screen-" || len($COLORTERM))
  "   set t_Co=256
  " endif
endif

" Local dirs"{{{1
set backupdir=~/.local/share/vim/backups
if ! isdirectory(expand(&backupdir))
  call mkdir( &backupdir, 'p', 0700 )
endif

if 1
  let vimcachedir=expand('~/.cache/vim')
  " XXX: not really a cache (https://github.com/tomtom/tmru_vim/issues/22)
  let g:tlib_cache = vimcachedir . '/tlib'
  let g:neocomplcache_temporary_dir = vimcachedir . '/neocomplcache'
  " TODO: cleanup
  let g:Powerline_cache_dir = vimcachedir . '/powerline'

  let vimconfigdir=expand('~/.config/vim')
  let g:session_directory = vimconfigdir . '/sessions'

  let vimsharedir = expand('~/.local/share/vim')
  let g:yankring_history_dir = vimsharedir
  let g:yankring_max_history = 500
  " let g:yankring_min_element_length = 2 " more that 1 breaks e.g. `xp`
  " Move yankring history from old location, if any..
  let s:old_yankring = expand('~/yankring_history_v2.txt')
  if filereadable(s:old_yankring)
    execute '!mv -i '.s:old_yankring.' '.vimsharedir
  endif

  " transfer any old tmru files to new location
  let g:tlib_persistent = vimsharedir
  let s:old_tmru_files = expand('~/.cache/vim/tlib/tmru/files')
  let s:new_tmru_files = vimsharedir.'/tmru/files'
  let s:new_tmru_files_dir = fnamemodify(s:new_tmru_files, ':h')
  if ! isdirectory(s:new_tmru_files_dir)
    call mkdir(s:new_tmru_files_dir, 'p', 0700)
  endif
  if filereadable(s:old_tmru_files)
    execute '!mv -i '.shellescape(s:old_tmru_files).' '.shellescape(s:new_tmru_files)
    " execute '!rm -r '.shellescape(g:tlib_cache)
  endif

  let g:tmru_file = s:new_tmru_files
end

let s:check_create_dirs = [vimcachedir, g:tlib_cache, g:neocomplcache_temporary_dir, g:Powerline_cache_dir, vimconfigdir, g:session_directory, vimsharedir]

if has('persistent_undo')
  let &undodir = vimsharedir . '/undo'
  set undofile
  call add(s:check_create_dirs, &undodir)
endif

for s:create_dir in s:check_create_dirs
  if ! isdirectory(s:create_dir)
    call mkdir(s:create_dir, 'p', 0700 )
  endif
endfor
" }}}

if has("user_commands")
  " enable pathogen, which allows for bundles in vim/bundle
  set rtp+=~/.vim/bundle/pathogen
  " filetype off

  let g:pathogen_disabled = [ 'golden-ratio', 'yankring' ]

  if ! s:use_ycm
    call add(g:pathogen_disabled, 'YouCompleteMe')
  endif
  if ! s:use_neocomplcache
    call add(g:pathogen_disabled, 'neocomplcache')
  endif
  " if s:use_ycm || s:use_neocomplcache
  "   call add(g:pathogen_disabled, 'supertab')
  " endif

  "
  " TO BE REMOVED"
  let g:pathogen_disabled += [ "shymenu" ]
  let g:pathogen_disabled += [ "easymotion" ]
  let g:pathogen_disabled += [ "yankstack" ]
  call pathogen#infect()

  " Themes
  " Airline:
  let g:airline_powerline_fonts = 1
  " to test
  let g:airline#extensions#branch#use_vcscommand = 1

  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#tabline#tab_nr_type = '[__tabnr__.%{len(tabpagebuflist(__tabnr__))}]'

  let g:airline#extensions#tmuxline#enabled = 1
  let g:airline#extensions#whitespace#enabled = 0

  let g:airline#extensions#tagbar#flags = 'f'  " full hierarchy of tag (with scope), see tagbar-statusline
  " see airline-predefined-parts
  "   let r += ['%{ShortenFilename(fnamemodify(bufname("%"), ":~:."), winwidth(0)-50)}']
  " function! AirlineInit()
  "   "   let g:airline_section_a = airline#section#create(['mode', ' ', 'foo'])
  "   "   let g:airline_section_b = airline#section#create_left(['ffenc','file'])
  "   "   let g:airline_section_c = airline#section#create(['%{getcwd()}'])
  " endfunction
  " au VimEnter * call AirlineInit()

  call airline#parts#define_function('file', 'ShortenFilenameWithSuffix')

  filetype plugin indent on

  " jedi-vim (besides YCM with jedi library) {{{1
  " let g:jedi#force_py_version = 3
  let g:jedi#auto_vim_configuration = 0
  let g:jedi#goto_assignments_command = 'gd'
  let g:jedi#goto_definitions_command = 'gD'
  let g:jedi#rename_command = 'cR'
  let g:jedi#usages_command = 'gr'
  let g:jedi#completions_enabled = 0

  " Unite/ref and pydoc are more useful.
  let g:jedi#documentation_command = '<Leader>_K'
  let g:jedi#show_call_signatures = 1
  if index(g:pathogen_disabled, 'jedi') != -1
    augroup JediVimEnter
      au!
      au VimEnter * call jedi#configure_call_signatures()
    augroup END
  endif

  let g:jedi#completions_enabled = 0

  let g:jedi#auto_close_doc = 1
    " if g:jedi#auto_close_doc
    "     " close preview if its still open after insert
    "     autocmd InsertLeave <buffer> if pumvisible() == 0|pclose|endif
    " end
  " }}}1
endif

" Enable syntax {{{1
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
" if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
if (&t_Co > 2 || has("gui_running"))
  syntax on " after 'filetype plugin indent on' (ref:
  set nohlsearch

  " Inject "TODO highlighting" via @Spell cluster (e.g. into cssComment)
  function! MyHighlightTodo()
    syn keyword MyTodo	  FIXME NOTE TODO OPTIMIZE XXX TODO: XXX:
    " XXX: using "Spell" (without "@") will disable spell checking with e.g. ft=mail!
    syn cluster @Spell add=MyTodo
  endfunction
  au Syntax * call MyHighlightTodo()
  hi def link MyTodo Todo
endif

if 1 " has('eval')
  " Color scheme (after 'syntax on') {{{1

  set bg=dark

  set rtp+=~/.vim/bundle/solarized

  " Set g:solarized_termcolors based on if terminal colors are setup for the 16 colors palette.
  if $TERM != 'linux' && $TERM != "fbterm" && ( $TERM != 'screen' || len($TMUX) || $HAS_SOLARIZED_COLORS == 1 )  " || $COLORTERM == 'gnome-terminal'
    " term with solarized color palette
    let g:solarized_termcolors=16
  else
    let g:solarized_termcolors=256
  endif
  " let g:solarized_italic=0
  " NOTE: using better-whitespace instead
  let g:solarized_hitrail=0
  colorscheme solarized

  " set rtp+=~/.vim/bundle/xoria256 " colorscheme
  " silent! colorscheme xoria256
  " set rtp+=~/.vim/bundle/colorscheme-detailed " colorscheme detailed

  " base16 (set of schemes) - not used currently {{{
  " We use a prepared 256color table:
"   let base16colorspace = 256
"
"   " Function to setup a base16 theme (Vim and shell)
"   fun! Base16Scheme(...)
"     if a:0
"       let name = a:1
"     else
"       if g:colors_name =~ '^base16-'
"         let name = substitute(g:colors_name, '^base16-', '', '')
"         echomsg "Reloading..."
"       else
"         echoerr "Base16Scheme: no name provided and current scheme is not base16 based"
"         return
"       endif
"     endif
"     " BASE16_SHELL_DIR points at the location of base16 shell files
"     " (https://github.com/chriskempson/base16-shell)
"     if len($BASE16_SHELL_DIR)
"       " if len($BASE16_SCHEME)
"         let shell_file = expand("$BASE16_SHELL_DIR/base16-".name.".dark.sh")
"         if !filereadable(shell_file)
"           echoerr "Base16Scheme: shell file does not exist: ".shell_file
"           return
"         endif
"         " Source the file
"         exe 'silent !source '.shellescape(shell_file)
"         if v:shell_error | echoerr "Could not source base16 shell file: ".shell_file | endif
"       " endif
"     else
"       " echomsg '$BASE16_SHELL_DIR is not set: cannot source shell script!'
"     endif
"     exec 'colorscheme base16-'.name
"   endfun
"
"   " Define Base16Scheme command to setup a scheme
"   function! s:get_base16_themes(a, l, p)
"     let files = split(globpath(&rtp, 'colors/base16-'.a:a.'*'), "\n")
"     return map(files, 'substitute(fnamemodify(v:val, ":t:r"), "base16-", "", "")')
"   endfunction
"   command! -nargs=? -complete=customlist,<sid>get_base16_themes Base16Scheme call Base16Scheme(<f-args>)
"
"
"   " " base16 scheme setup based on env
"   " if len($BASE16_SCHEME)
"   "   " echomsg "Using theme:" $BASE16_SCHEME
"   "   exec 'Base16Scheme '.substitute($BASE16_SCHEME, '\.dark', '', '')
"   " else
"   "   Base16Scheme solarized
"   " endif
"   " colorscheme jellybeans
"
"   " if &bg == 'dark'
"   "   colorscheme jellybeans
"   " else
"   "   " Base16Scheme solarized
"   "   colorscheme solarized
"   "   " pimp colors (base16-solarized)
"   "   " hi Search ctermfg=130 ctermbg=21 cterm=underline
"   "   " hi IncSearch ctermfg=130 ctermbg=21 cterm=reverse
"   " endif
"   " }}}
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd") " Autocommands {{{1
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " Enable soft-wrapping for text files
  au FileType text,markdown,html,xhtml,eruby,vim setlocal wrap linebreak nolist
  au FileType mail,markdown,gitcommit setlocal spell
  au FileType json setlocal equalprg=json_pp

  " XXX: only works for whole files
  " au FileType css  setlocal equalprg=csstidy\ -\ --silent=true\ --template=default

  " For all text files set 'textwidth' to 78 characters.
  " au FileType text setlocal textwidth=78

  " Follow symlinks when opening a file {{{
  " NOTE: this happens with directory symlinks anyway (due to Vim's chdir/getcwd
  "       magic when getting filenames).
  " Sources:
  "  - https://github.com/tpope/vim-fugitive/issues/147#issuecomment-7572351
  "  - http://www.reddit.com/r/vim/comments/yhsn6/is_it_possible_to_work_around_the_symlink_bug/c5w91qw
  function! MyFollowSymlink(...)
    if exists('w:no_resolve_symlink') && w:no_resolve_symlink
      return
    endif
    let fname = a:0 ? a:1 : expand('%')
    if fname =~ '^\w\+:/'
      " do not mess with 'fugitive://' etc
      return
    endif
    let fname = simplify(fname)

    let resolvedfile = resolve(fname)
    if resolvedfile == fname
      return
    endif
    let resolvedfile = fnameescape(resolvedfile)
    if &modifiable
      " Only display a warning when editing a file, especially not for `:help`.
      echohl WarningMsg | echomsg 'Resolving symlink' fname '=>' resolvedfile | echohl None
    endif
    " exec 'noautocmd file ' . resolvedfile
    " XXX: problems with AutojumpLastPosition: line("'\"") is 1 always.
    let sshm = &shm
    set shortmess+=A  " silence ATTENTION message about swap file (would get displayed twice)
    exec 'silent file ' . resolvedfile
    let &shm=sshm
  endfunction
  command! FollowSymlink call MyFollowSymlink()
  command! ToggleFollowSymlink let w:no_resolve_symlink = !get(w:, 'no_resolve_symlink', 0) | echo "w:no_resolve_symlink =>" w:no_resolve_symlink
  au BufReadPost * nested call MyFollowSymlink(expand('<afile>'))

  " Jump to last known cursor position on BufReadPost {{{
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " NOTE: read viminfo/marks, but removed: causes issues with jumplist sync
  " across Vim instances
    " \   rviminfo |
  " NOTE: removed for SVN commit messages: && fnamemodify(bufname('%'), ':t') != 'svn-commit.tmp'
  fun! AutojumpLastPosition()
    if ! exists('b:autojumped_init')
      let b:autojumped_init = 1
      if &ft != 'gitcommit' && &ft != 'diff' && ! &diff && line("'\"") <= line("$")
        exe 'normal! g`"zv'
      endif
    endif
  endfun
  au BufReadPost * call AutojumpLastPosition()
  " }}}

  " Automatically load .vimrc source when saved
  au BufWritePost $MYVIMRC,~/.dotfiles/vimrc,$MYVIMRC.local source $MYVIMRC
  au BufWritePost $MYGVIMRC,~/.dotfiles/gvimrc source $MYGVIMRC

  " if (has("gui_running"))
  "   au FocusLost * stopinsert
  " endif

  " autocommands for fugitive {{{2
  " Source: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
  au User fugitive
    \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)' |
    \   nnoremap <buffer> .. :edit %:h<CR> |
    \ endif
  au BufReadPost fugitive://* set bufhidden=delete

  " Expand tabs for Debian changelog. This is probably not the correct way.
  au BufNewFile,BufRead debian/changelog,changelog.dch set expandtab

  " Python
  au FileType python setlocal tabstop=4 shiftwidth=4 expandtab autoindent foldmethod=expr
  " from pymode, minus relativenumber (~/vim/bundle/python-mode/ftplugin/python/pymode.vim)
  au FileType python setlocal complete+=t formatoptions-=t nowrap textwidth=79

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

  " Trailing whitespace highlighting {{{2
  " Map to toogle EOLWS syntax highlighting
  noremap <silent> <leader>se :let g:MyAuGroupEOLWSactive = (synIDattr(synIDtrans(hlID("EOLWS")), "bg", "cterm") == -1)<cr>
        \:call MyAuGroupEOLWS(mode())<cr>
  let g:MyAuGroupEOLWSactive = 0
  function! MyAuGroupEOLWS(mode)
    if g:MyAuGroupEOLWSactive && &buftype == ''
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
    " highlight EOLWS ctermbg=red guibg=red
    " based on solarizedTrailingSpace
    highlight EOLWS term=underline cterm=underline ctermfg=1
    au InsertEnter * call MyAuGroupEOLWS("i")
    " highlight trailing whitespace, space before tab and tab not at the
    " beginning of the line (except in comments), only for normal buffers:
    au InsertLeave,BufWinEnter * call MyAuGroupEOLWS("n")
      " fails with gitcommit: filetype  | syn match EOLWS excludenl /[^\t]\zs\t\+/ containedin=ALLBUT,gitcommitComment

    " add this for Python (via python_highlight_all?!):
    " au FileType python
    "       \ if g:MyAuGroupEOLWSactive |
    "       \ syn match EOLWS excludenl /^\t\+/ containedin=ALL |
    "       \ endif
  augroup END "}}}

  " automatically save and reload viminfo across Vim instances
  " Source: http://vimhelp.appspot.com/vim_faq.txt.html#faq-17.3
  augroup viminfo_onfocus
    au!
    " au FocusLost   * wviminfo
    " au FocusGained * rviminfo
  augroup end
endif " has("autocmd") }}}

" statusline {{{
" old
" set statusline=%t%<%m%r%{fugitive#statusline()}%h%w\ [%{&ff}]\ [%Y]\ [\%03.3b]\ [%04l,%04v][%p%%]\ [%L\ lines\]

" Shorten a given filename by truncating path segments.
let s:_cache_shorten_path = {}
fun! ShortenPath(path)
  if ! len(a:path)
    return ''
  endif
  if ! exists('s:_cache_shorten_path[a:path]')
    let s:_cache_shorten_path[a:path] = system('shorten_path '.shellescape(a:path))
  endif
  return s:_cache_shorten_path[a:path]
endfun

" Shorten a given filename by truncating path segments.
let g:_cache_shorten_filename = {}
function! ShortenFilename(...)  " {{{
  " Args: bufname ('%' for default), maxlength
  " echomsg "ShortenFilename:" string(a:000)

  " get bufname from a:1, defaulting to bufname('%') {{{
  if a:0 && a:1 != '%'
    let bufname = a:1
  else
    let bufname = bufname("%")
    if !len(bufname)
      if len(&ft)
        " use &ft for name (e.g. with 'startify'
        return '['.&ft.']'
      else
        " TODO: get Vim's original "[No Name]" somehow
        return '[No Name]'
      endif
    end

    if getbufvar(bufnr(bufname), '&filetype') == 'help'
      return '[?] '.fnamemodify(bufname, ':t')
    endif

    if bufname =~ '^__'
      return bufname
    endif
  endif
  " }}}

  " Maxlen from a:2 (used for cache key) and caching. {{{
  let maxlen = a:0>1 ? a:2 : max([10, winwidth(0)-50])
  " echom maxlen a:0
  " if a:0>1 | echom a:2 | endif

  " Check for cache (avoiding fnamemodify):
  let cache_key = escape(bufname.'::'.getcwd().'::'.maxlen, "'")
  if exists("g:_cache_shorten_filename['".cache_key."']")
    return g:_cache_shorten_filename[cache_key]
  endif

  " let fullpath = fnamemodify(bufname, ':p')
  let bufname = fnamemodify(bufname, ":p:~:.")
  let bufname = ShortenPath(bufname)  " uses internal cache
  " }}}

  " Loop over all segments/parts, to mark symlinks.
  " XXX: symlinks get resolved currently anyway!?
  " NOTE: consider using another method like http://stackoverflow.com/questions/13165941/how-to-truncate-long-file-path-in-vim-powerline-statusline
  let maxlen_of_parts = 7 " including slash/dot
  let maxlen_of_subparts = 5 " split at dot/hypen/underscore; including split

  let s:PS = exists('+shellslash') ? (&shellslash ? '/' : '\') : "/"
  let parts = split(bufname, '\ze['.escape(s:PS, '\').']')
  let i = 0
  let n = len(parts)
  let wholepath = '' " used for symlink check
  while i < n
    let wholepath .= parts[i]
    " Shorten part, if necessary:
    if i < n-1 && len(bufname) > maxlen && len(parts[i]) > maxlen_of_parts
      " Let's see if there are dots or hyphens to truncate at, e.g.
      " 'vim-pkg-debian' => 'v-p-d…'
      let w = split(parts[i], '\ze[._-]')
      if len(w) > 1
        let parts[i] = ''
        for j in w
          if len(j) > maxlen_of_subparts-1
            let parts[i] .= j[0:maxlen_of_subparts-2]."…"
          else
            let parts[i] .= j
          endif
        endfor
      else
        let parts[i] = parts[i][0:maxlen_of_parts-2].'…'
      endif
    endif
    " Add indicator if this part of the filename is a symlink.
    if getftype(wholepath) == "link"
      if parts[i][0] == s:PS
        let parts[i] = parts[i][0] . '↬ ' . parts[i][1:]
      else
        let parts[i] = '↬ ' . parts[i]
      endif
    endif
    let i += 1
  endwhile
  let r = join(parts, '')
  let g:_cache_shorten_filename[cache_key] = r
  " echom "ShortenFilename" r
  return r
endfunction "}}}

" Shorten filename, and append suffix(es), e.g. for modified buffers. {{{2
fun! ShortenFilenameWithSuffix(...)
  let r = call('ShortenFilename', a:000)
  if &buftype == ''
    if &modified
      let r .= ',+'
    endif
  endif
  return r
endfun
" }}}

if 0 && has('statusline') " disabled {{{10
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

" colorize start of statusline according to file status,
" source: http://www.reddit.com/r/vim/comments/gexi6/a_smarter_statusline_code_in_comments/c1n2oo5
hi StatColor guibg=#95e454 guifg=black ctermbg=lightgreen ctermfg=black
hi Modified guibg=orange guifg=black ctermbg=lightred ctermfg=black
function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    hi StatColor guibg=orange guifg=black ctermbg=lightred ctermfg=black
  elseif a:mode == 'r'
    hi StatColor guibg=#e454ba guifg=black ctermbg=magenta ctermfg=black
  elseif a:mode == 'v'
    hi StatColor guibg=#e454ba guifg=black ctermbg=magenta ctermfg=black
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
  " Shorten filename while reserving 50 characters for the rest of the statusline.
  let r += ['%{ShortenFilename(fnamemodify(bufname("%"), ":~:."), winwidth(0)-50)}']
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
  let r += ['%-12(L%l/%L:C%c%V%)'] " Current line and column
  " let r += ['%l/%L']   "cursor line/total lines
  let r += [' %P']    "percent through file
  return join(r, '')
endfunction
endif "}}}
"}}}


" (gui)tablabel {{{
function! GuiTabLabel()
  let label = ''
  let bufnrlist = tabpagebuflist(v:lnum)

  let label .= tabpagenr().':'

  " Add '+' if one of the buffers in the tab page is modified
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let label .= '+'
      break
    endif
  endfor

  " Append the buffer name
  " let label .= fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':~:.')
  let label .= ShortenFilename(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), 20)

  " Append the number of windows in the tab page if more than one
  let wincount = tabpagewinnr(v:lnum, '$')
  if wincount > 1
    let label .= ' ('.wincount.')'
  endif
  return label
endfunction
set guitablabel=%{GuiTabLabel()}
" }}}


" Hide search highlighting
if has('extra_search')
  nnoremap <silent> <Leader>h :set hlsearch!<CR>:set hlsearch?<CR>
  nnoremap <silent> <Leader><C-l> :nohlsearch<CR><C-l>
  inoremap <silent> <C-l> <C-o>:nohlsearch<bar>redraw<CR>
endif

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>ee :e <C-R>=expand("%:p:h") . "/" <CR>

" gt: next tab or buffer (source: http://j.mp/dotvimrc)
"     enhanced to support range (via v:count)
fun! MyGotoNextTabOrBuffer(...)
  let c = a:0 ? a:1 : v:count
  echom count
  exec (c ? c : '') . (tabpagenr('$') == 1 ? 'bn' : 'tabnext')
endfun
fun! MyGotoPrevTabOrBuffer()
  exec (v:count ? v:count : '') . (tabpagenr('$') == 1 ? 'bp' : 'tabprevious')
endfun
" nmap <silent> <Plug>NextTabOrBuffer :<C-U>exec (v:count ? v:count : '') . (tabpagenr('$') == 1 ? 'bn' : 'tabnext')<CR>
" nmap <silent> <Plug>PrevTabOrBuffer :<C-U>exec (v:count ? v:count : '') . (tabpagenr('$') == 1 ? 'bp' : 'tabprevious')<CR>
nmap <silent> <Plug>NextTabOrBuffer :<C-U>call MyGotoNextTabOrBuffer()<CR>
nmap <silent> <Plug>PrevTabOrBuffer :<C-U>call MyGotoPrevTabOrBuffer()<CR>

" NOTE: <C-N> used for GoldenViewNext
" nmap <C-N> :tabnew<cr>
" Ctrl-Space
nmap <C-Space> :tabnew<cr>
" For terminal.
nmap <C-@> :tabnew<cr>

" Opens a tab edit command with the path of the currently edited file filled in
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

map <a-o> <C-W>o

" does not work, even with lilyterm.. :/
" TODO: <C-1>..<C-0> for tabs; not possible; only certain C-sequences get
" through to the terminal Vim
" nmap <C-Insert> :tabnew<cr>
" nmap <C-Del> :tabclose<cr>
nmap <A-Del> :tabclose<cr>
" nmap <C-1> 1gt<cr>

nmap <C-PageUp> <Plug>PrevTabOrBuffer
nmap <C-PageDown> <Plug>NextTabOrBuffer

map <A-,>     <Plug>PrevTabOrBuffer
map <A-.>     <Plug>NextTabOrBuffer
map <C-S-Tab> <Plug>PrevTabOrBuffer
map <C-Tab>   <Plug>NextTabOrBuffer

" Switch to most recently used tab
" Source: http://stackoverflow.com/a/2120168/15690
fun! MyGotoMRUTab()
  if !exists('g:mrutab')
    let g:mrutab = 1
  endif
  if g:mrutab > tabpagenr('$') || g:mrutab == tabpagenr()
    if g:mrutab > 1
      " go to the left
      let g:mrutab = tabpagenr()-1
    else
      echomsg "There is only one tab!"
      return
    endif
  endif
  exe "tabn ".g:mrutab
endfun
" XXX: stupid map
nmap gh :call MyGotoMRUTab()<CR>
" nmap <tab><tab> :call MyGotoMRUTab()<CR>
" nmap °  :call MyGotoMRUTab()<CR>
nmap <C-^>  :call MyGotoMRUTab()<CR>
augroup MyTL
  au!
  au TabLeave * let g:mrutab = tabpagenr()
augroup END

" Map <A-1> .. <A-9> to goto tab or buffer.
for i in range(9)
  exec 'nmap <M-' .(i+1).'> :call MyGotoNextTabOrBuffer('.(i+1).')<cr>'
endfor

" titlestring handling, with tmux support {{{
" Change tmux window name (used in window list) {{{
if 0 && len($TMUX_PANE)
  if len($_tmux_title_is_auto_set)
    " Use exported state from Zsh (if any)
    let g:tmux_auto_rename_window = $_tmux_title_is_auto_set
  else
    " look at tmux' automatic-rename option
    let s:tmux_auto_set = system('tmux show-window-options -t $TMUX_PANE -v automatic-rename 2>/dev/null')
    if v:shell_error
      let s:tmux_auto_set = system('tmux show-window-options -t $TMUX_PANE | grep "^automatic-rename" | cut -f2 -d\ ')
    endif
    " TODO: look for marker (﻿) at end of current title
    let g:tmux_auto_rename_window = s:tmux_auto_set =~ '^off' ? 0 : 1
  endif
  augroup tmuxtitle
    au!
    " au BufReadPost,FileReadPost,BufNewFile * call MySetTmuxWindowTitle('vi: '.expand('%:t'))
    " au BufWinEnter,WinEnter * call MySetTmuxWindowTitle('vi: '.expand('%:t'))"{{{"}}}
    " BufReadPost,FileReadPost,BufNewFile from http://stackoverflow.com/a/15124717/15690
    " FocusGained: not working with tmux, but should (when coming back from
    " another pane)
    " XXX: not called after returning/quitting :Gdiff; https://github.com/tpope/vim-fugitive/issues/421
    " au FocusGained,BufWinEnter,WinEnter * call MySetTmuxWindowTitle(ShortenFilename('%', 15))
    " au BufEnter,BufWinEnter,WinEnter * echomsg "BufEnter"
    au BufEnter,BufFilePost * call MySetTmuxWindowTitle(ShortenFilename('%', 15))
  augroup END
endif " }}}

fun! MyGetPrettyFileDir()
  " TODO: use shorten_path / abstract it
  let dir=expand('%:~:h')
  if len(dir) && dir != '.'
    return '('.dir.')'
  endif
  return ''
endfun

fun! MySetTmuxWindowTitle(title)
  " echom "MySetTmuxWindowTitle" a:title
  " return early, if unchanged
  if a:title == g:_last_tmux_win_title | return | endif

  " call tmux according to g:tmux_auto_rename_window setting
  if exists('g:tmux_auto_rename_window') && g:tmux_auto_rename_window
    " tmux title: prefix and marker for "auto-renamed"
    let s:tmux_title = '✐ '.a:title.'﻿'
    call system('tmux rename-window -t $TMUX_PANE '.shellescape(s:tmux_title))
    let g:_last_tmux_win_title = a:title
  endif
endfun
let g:_last_tmux_win_title = ''

" Set titlestring, used to set terminal title (pane title in tmux). {{{2
set title
" Setup titlestring on VimEnter, when v:servername is available.
" set titlestring=✐\ %t%M%R%(\ %<%{MyGetPrettyFileDir()}%)
fun! MySetupTitleString()
  let &titlestring = '✐'

  " Use / auto-set g:MySessionName
  if (!exists("g:MySessionName") || !len(g:MySessionName)) && exists('v:this_session')
    let g:MySessionName = fnamemodify(v:this_session, ':t:r')
  endif
  if exists("g:MySessionName") && len(g:MySessionName)
    let &titlestring .= ' ['.g:MySessionName.']'
  else
    " Add non-default servername to titlestring.
    let sname = MyGetNonDefaultServername()
    if len(sname)
      let &titlestring .= ' ['.sname.']'
    endif
  endif

  " let &titlestring .= ': %t%M%R%( %<%{MyGetPrettyFileDir()}%)'
  let &titlestring .= '%( %<%{ShortenFilenameWithSuffix(''%'', 15)}%)'

  " easier to type/find than the unicode symbol prefix.
  let &titlestring .= ' - vim'

  " Append $_TERM_TITLE_SUFFIX to title (set via zsh, used with SSH).
  if len($_TERM_TITLE_SUFFIX)
    let &titlestring .= $_TERM_TITLE_SUFFIX
  endif
endfun
if has('vim_starting')
  au! VimEnter,SessionLoadPost * call MySetupTitleString()
else
  call MySetupTitleString()
endif

fun! MySetSessionName(name)
  let g:MySessionName = a:name
  call MySetupTitleString()
endfun
"}}}

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
" cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Change to current file's dir
nmap <Leader>cd :lcd <C-R>=expand('%:p:h')<CR><CR>

" yankstack, to be replaced by unite's history/yank {{{1
if index(g:pathogen_disabled, 'yankring') == -1
  " Define own map for yankstack, Alt-p/esc-p does not work correctly in term.
  let g:yankstack_map_keys = 0
  " Setup yankstack to make yank/paste related mappings work.
  " þ => altgr-p
  call yankstack#setup()
  nmap þ <Plug>yankstack_substitute_older_paste
  xmap þ <Plug>yankstack_substitute_older_paste
  imap þ <Plug>yankstack_substitute_older_paste
  nmap þ <Plug>yankstack_substitute_newer_paste
  xmap þ <Plug>yankstack_substitute_newer_paste
  imap þ <Plug>yankstack_substitute_newer_paste
endif


" sneak {{{1
" Overwrite yankstack with sneak maps.
" Ref: https://github.com/maxbrunsfeld/vim-yankstack/issues/39
nmap s <Plug>Sneak_s
nmap S <Plug>Sneak_S
xmap s <Plug>Sneak_s
xmap S <Plug>Sneak_S

let g:sneak#streak=1
" g:sneak#target_labels = "asdfghjkl;qwertyuiopzxcvbnm/ASDFGHJKL:QWERTYUIOPZXCVBNM?"
let g:sneak#target_labels = "asdfghjklöä"

" " Replace 'f' with inclusive 1-char Sneak.
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F
" Replace 't' with exclusive 1-char Sneak.
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T
" IDEA: just use 'f' for sneak, leaving 's' at its default.
" nmap f <Plug>Sneak_s
" nmap F <Plug>Sneak_S
" xmap f <Plug>Sneak_s
" xmap F <Plug>Sneak_S
" omap f <Plug>Sneak_s
" omap F <Plug>Sneak_S
" }}}1


" Duplicate a selection in visual mode
vmap D y'>p

" Press Shift+P while in visual mode to replace the selection without
" overwriting the default register
vmap P p :call setreg('"', getreg('0')) <CR>

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

" imap <C-L> <Space>=><Space>

" toggle settings, mnemonic "set paste", "set wrap", ..
" NOTE: see also unimpaired
set pastetoggle=<leader>sp
nmap <leader>sc :ColorToggle<cr>
nmap <leader>sq :QuickfixsignsToggle<cr>
nmap <leader>si :IndentGuidesToggle<cr>

" let g:colorizer_fgcontrast=-1
let g:colorizer_startup = 0

" OLD: Ack/Ag setup, handled via ag plugin {{{
" Use Ack instead of Grep when available
" if executable("ack")
"   set grepprg=ack\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
" elseif executable("ack-grep")
"   set grepprg=ack-grep\ -H\ --nogroup\ --nocolor\ --ignore-dir=tmp\ --ignore-dir=coverage
" else
   " this is for Windows/cygwin and to add -H
   " '$*' is not passed to the shell, but used by Vim
   set grepprg=grep\ -nH\ $*\ /dev/null
" endif

if executable("ag")
  let g:ackprg = 'ag --nogroup --nocolor --column'
  " command alias, http://stackoverflow.com/a/3879737/15690
  " if re-used, use a function
  " cnoreabbrev <expr> Ag ((getcmdtype() is# ':' && getcmdline() is# 'Ag')?('Ack'):('Ag'))
endif
" 1}}}

" Automatic line numbers {{{
" au BufReadPost * if &bt == "quickfix" || ! exists('+relativenumber') | set number | else | set relativenumber | endif | call SetNumberWidth()
set nonumber
let &showbreak = '↪ '
function! CycleLineNr()
  " states: [start] => norelative/number => relative/number => relative/nonumber => nonumber/norelative
  if exists('+relativenumber')
    if &relativenumber
      if &number
        set relativenumber nonumber
      else
        set norelativenumber nonumber
      endif
    else
      if &number
        set relativenumber number
      else
        " init:
        set norelativenumber number
      endif
    endif
    " if &number | set relativenumber | elseif &relativenumber | set norelativenumber | else | set number | endif
  else
    set number!
  endif
  call SetNumberWidth()
  if &relativenumber == 0 && &number == 0
    let &showbreak='↪ '
  else
    set showbreak= " not required with line numbers
  endif
endfunction
function! SetNumberWidth()
  " NOTE: 'numberwidth' will get expanded by Vim automatically to fit the last line
  if &number
    if has('float')
      let &l:numberwidth = float2nr(ceil(log10(line('$'))))
    endif
  elseif exists('+relativenumber') && &relativenumber
    set numberwidth=2
  endif
endfun
nmap <leader>sa :call CycleLineNr()<CR>

" Toggle numbers, but with relativenumber turned on
fun! ToggleLineNr()
  if &number
    if exists('+relativenumber')
      set norelativenumber
    endif
    set nonumber
  else
    if exists('+relativenumber')
      set relativenumber
    endif
    set number
  endif
endfun
" map according to unimpaired, mnemonic "a on the left, like numbers".
nmap coa :call ToggleLineNr()<cr>

" Allow cursor to move anywhere in all modes.
nnoremap cov :set <C-R>=empty(&virtualedit) ? 'virtualedit=all' : 'virtualedit='<CR><CR>
"}}}

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
" set completeopt=longest,menu
set completeopt=menuone
" set completeopt=menuone,preview  " experimental
set wildmode=list:longest,list:full
" set complete+=kspell " complete from spell checking
" set dictionary+=spell " very useful (via C-X C-K), but requires ':set spell' once
if has("autocmd") && exists("+omnifunc")
  augroup filetype_omnifunc
  au!
  au Filetype *
    \   if &omnifunc == "" |
    \     setlocal omnifunc=syntaxcomplete#Complete |
    \   endif
  " use eclim for PHP omnicompletion (does not pollute quickfix window and is better in general)
  "  au Filetype php setlocal omnifunc=eclim#php#complete#CodeComplete
  " ref: https://github.com/Valloric/YouCompleteMe/issues/103#issuecomment-14149318
  " NOTE: this is done via g:EclimCompletionMethod now instead
  " au Filetype * runtime! autoload/eclim/<amatch>/complete.vim
  "   \	| let s:cfunc = 'eclim#'.expand('<amatch>').'#complete#CodeComplete'
  "   \	| if exists('*'.s:cfunc) | let &l:omnifunc=s:cfunc | endif
  augroup END
endif


" set cursorline
" highlight CursorLine guibg=lightblue ctermbg=lightgray

" Make the current status line stand out, e.g. with xoria256 (using the
" PreProc colors from there)
" hi StatusLine      ctermfg=150 guifg=#afdf87

" via http://www.reddit.com/r/programming/comments/7yk4i/vim_settings_per_directory/c07rk9d
" :au! BufRead,BufNewFile *path/to/project/*.* setlocal noet

" Maps for jk and kj to act as Esc (idempotent in normal mode).
" NOTE: jk moves to the right after Esc, leaving the cursor at the current position.
ino jk <esc>l
" cno jk <c-c>
ino kj <esc>
" cno kj <c-c>


" close tags (useful for html)
" NOTE: not required/used; avoid imap for leader.
" imap <Leader>/ </<C-X><C-O>

nnoremap <Leader>a :Ag<space>
nnoremap <Leader><Leader>a :Ack!<space>

" Make those behave like ci' , ci"
nnoremap ci( f(ci(
nnoremap ci{ f{ci{
nnoremap ci[ f[ci[

vnoremap ci( f(ci(
vnoremap ci{ f{ci{
vnoremap ci[ f[ci[

" 'goto buffer'; NOTE: overwritten with Unite currently.
nnoremap gb :ls<CR>:b

function! MyIfToVarDump()
  normal yyP
  s/\mif\>/var_dump/
  s/\m\s*\(&&\|||\)\s*/, /ge
  s/\m{\s*$/; die();/
endfunction

" nmap <Space><Space> cox

" Toggle folds
nnoremap <Leader><space> za
vnoremap <Leader><space> zf

" Easily switch between different fold methods {{{
" Source: https://github.com/pydave/daveconfig/blob/master/multi/vim/.vim/bundle/foldtoggle/plugin/foldtoggle.vim
nnoremap <Leader>ff :call ToggleFold()<CR>
function! ToggleFold()
        if !exists("b:fold_toggle_options")
                " By default, use the main three. I rarely use custom expressions or
                " manual and diff is just for diffing.
                let b:fold_toggle_options = ["syntax", "indent", "marker"]
        endif

        " Find the current setting in the list
        let i = match(b:fold_toggle_options, &foldmethod)

        " Advance to the next setting
        let i = (i + 1) % len(b:fold_toggle_options)
        let &l:foldmethod = b:fold_toggle_options[i]

        echo 'foldmethod is now ' . &l:foldmethod
endfunction

function! FoldParagraphs()
    setlocal foldmethod=expr
    setlocal fde=getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1
endfunction
command! FoldParagraphs call FoldParagraphs()
" }}}

" Paste register `reg`, while remembering current state of &paste
function! MyPasteRegister(reg, mode)
  let at_end_of_line = (col(".") >= col("$")-1)
  echomsg "DEBUG" col(".") "/" col("$") "/ eol? " at_end_of_line

  let pastecmd = 'P'
  if a:mode == 'i'
    if at_end_of_line
      normal l
      let pastecmd = 'p'
    endif
  endif
  " if at_end_of_line && a:mode == 'i'
  " if a:mode == 'i'
  "   let pastecmd = 'p'
  " else
  "   let pastecmd = 'P'
  " endif
  exec 'normal "' . a:reg . pastecmd
  " go to end of paste and right
  normal ']l
  " if a:mode == 'i'
  "   if at_end_of_line
  "     " like ":normal A"
  "     return "startinsert!"
  "   else
  "     " like ":normal i"
  "     return "startinsert"
  "   endif
  " endif
  return '' " not relevant for a:mode=='n'
endfunction
" deactivated: using regular/unimpaired pasting; avoid Leader map in insert mode
" imap <Leader>v  <C-O>:call MyPasteRegister("+", "i")<CR>
" imap <Leader>V  <C-O>:call MyPasteRegister("*", 'i')<CR>
" nmap <Leader>v       :call MyPasteRegister("+", 'n')<CR>
" nmap <Leader>V       :call MyPasteRegister("*", 'n')<CR>

" Map S-Insert to insert the "*" register literally.
if has('gui')
  " nmap <S-Insert> <C-R><C-o>*
  " map! <S-Insert> <C-R><C-o>*
  nmap <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif


" swap previously selected text with currently selected one (via http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines#Visual-mode_swapping)
vnoremap <C-X> <Esc>`.``gvP``P

" Sudo write
" Using SudoEdit instead (https://github.com/chrisbra/SudoEdit.vim)
" if executable('sudo') && executable('tee')
"   command! SUwrite
"         \ execute 'w !sudo tee % > /dev/null' |
"         \ setlocal nomodified
" endif


" Easy indentation in visual mode
" This keeps the visual selection active after indenting.
" Usually the visual selection is lost after you indent it.
"vmap > >gv
"vmap < <gv

" Make `<leader>gp` select the last pasted text
" (http://vim.wikia.com/wiki/Selecting_your_pasted_text).
nnoremap <expr> <leader>gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Syntax Checking entire file (Python)
" Usage: :make (check file)
" :clist (view list of errors)
" :cn, :cp (move around list of errors)
" NOTE: should be provided by checksyntax plugin
" au BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
" au BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

if 1 " has('eval') {{{1
" Strip trailing whitespace {{{2
function! StripWhitespace(line1, line2, ...)
  let pattern = a:0 ? a:1 : '[\\]\@<!\s\+$'
  if exists('*winsaveview')
    let oldview = winsaveview()
  else
    let old_query = getreg('/')
    let save_cursor = getpos(".")
  endif
  " let old_linenum = line('.')
  exe 'keepjumps keeppatterns '.a:line1.','.a:line2.'substitute/'.pattern.'//e'
  if exists('oldview')
    call winrestview(oldview)
  else
    call setpos('.', save_cursor)
  endif
  " call setreg('/', old_query)
  " keepjumps exe "normal " . old_linenum . "G"
endfunction
command! -range=% Untrail keepjumps call StripWhitespace(<line1>,<line2>)
" Untrail, for pastes from tmux (containing border).
command! -range=% UntrailSpecial keepjumps call StripWhitespace(<line1>,<line2>,'[\\]\@<!\s\+│\?$')
noremap <leader>st :Untrail<CR>

" Execute current line/selection.
" Merge escaped newlines.
command! -range ExecThis <line1>,<line2>yank t | let @t=substitute(@t, '\v\n\s*\\', ' ', 'g') | @t
map <Leader>< :ExecThis<cr>

command! RR ProjectRootLCD
command! RRR ProjectRootCD

" Toggle pattern (typically a char) at the end of line {{{2
function! MyToggleLastChar(pat)
  let view = winsaveview()
  try
    keepjumps keeppatterns exe 's/\([^'.escape(a:pat,'/').']\)$\|^$/\1'.escape(a:pat,'/').'/'
  catch /^Vim\%((\a\+)\)\=:E486: Pattern not found/
    keepjumps keeppatterns exe 's/'.escape(a:pat, '/').'$//'
  finally
    call winrestview(view)
  endtry
endfunction
noremap <Leader>; :call MyToggleLastChar(';')<cr>
noremap <Leader>: :call MyToggleLastChar(':')<cr>
noremap <Leader>, :call MyToggleLastChar(',')<cr>
noremap <Leader>. :call MyToggleLastChar('.')<cr>
noremap <Leader>qa :call MyToggleLastChar('  # noqa')<cr>

" use 'en_us' also to work around matchit considering 'en' as 'endif'
set spl=de,en_us
" Toggle spellang: de => en => de,en
fun! MyToggleSpellLang()
  if &spl == 'de,en'
    set spl=en
  elseif &spl == 'en'
    set spl=de
  else
    set spl=de,en
  endif
  echo "Set spl to ".&spl
endfun
noremap <Leader>sts :call MyToggleSpellLang()<cr>

" Grep in the current (potential unsaved) buffer {{{2
" NOTE: obsolete with Unite.
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
" nnoremap <leader><space> :GrepCurrentBuffer <C-r><C-w><cr>


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
    " NOTE: problematic with Unite's directory, when opening a file:
    " :Unite from startify, then quitting Unite quits Vim.
        " \ || &ft == 'startify'
    q
  endif
endfunction
augroup CloseIfOnlyControlWinLeft
  au!
  au WinEnter * call s:CloseIfOnlyControlWinLeft()
augroup END


" Check for file modifications automatically
" (current buffer only)
" Use :NoAutoChecktime to disable it (uses b:autochecktime)
fun! MyAutoCheckTime()
  " only check timestamp for normal files
  if &buftype != '' | return | endif
  if ! exists('b:autochecktime') || b:autochecktime
    checktime %
    let b:autochecktime = 1
  endif
endfun
augroup MyAutoChecktime
  au!
  au FocusGained,BufEnter,CursorHold * call MyAutoCheckTime()
augroup END
command! NoAutoChecktime let b:autochecktime=0

" vcscommand: only used as lib for detection (e.g. with airline). {{{1
" Setup b:VCSCommandVCSType.
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
let g:VCSCommandDisableMappings = 1
" }}}1

" Open Windows explorer and select current file
if executable('explorer.exe')
  command! Winexplorer :!start explorer.exe /e,/select,"%:p:gs?/?\\?"
endif

" do not pick last item automatically (non-global: g:tmru_world.tlib_pick_last_item)
let g:tlib_pick_last_item = 1
let g:tlib_inputlist_match = 'cnf'
let g:tmruSize = 500
let g:tlib#cache#purge_days = 365
" let g:tmru#display_relative_filename = 1 " default: 0
" let g:tlib#input#format_filename = 'r' " default: 'l', required for
" display_relative_filename
let g:tmru_world = {}
let g:tmru_world.cache_var = 'g:tmru_cache'
let g:tmru#drop = 0 " do not `:drop` to files in existing windows. XXX: should use/follow &switchbuf maybe?! XXX: not documented
let g:tmru_sessions = 9 " disable

" Easytags
let g:easytags_on_cursorhold = 0 " disturbing, at least on work machine
let g:easytags_cmd = 'ctags'
let g:easytags_suppress_ctags_warning = 1
" let g:easytags_dynamic_files = 1
let g:easytags_resolve_links = 1

let g:detectindent_preferred_indent = 2 " used for sw and ts if only tabs
let g:detectindent_min_indent = 2  " via https://github.com/raymond-w-ko/detectindent
let g:detectindent_max_indent = 4  " via https://github.com/raymond-w-ko/detectindent

" command-t plugin {{{
let g:CommandTMaxFiles=50000
let g:CommandTMaxHeight=20
let g:CommandTFileScanner='find'
if has("autocmd") && exists(":CommandTFlush") && has("ruby")
  " this is required for Command-T to pickup the setting(s)
  au VimEnter * CommandTFlush
endif
if (has("gui_running"))
  " use Alt-T in GUI mode
  map <A-t> :CommandT<CR>
endif
map <leader>tt :CommandT<CR>
map <leader>t. :execute "CommandT ".expand("%:p:h")<cr>
map <leader>t  :CommandT<space>
map <leader>tb :CommandTBuffer<CR>
" }}}

" supertab.vim {{{
  if &rtp =~ '\<supertab\>'
    let g:SuperTabDefaultCompletionType = 'context'
    let g:SuperTabContextTextFileTypeExclusions =
      \ ['htmldjango', 'htmljinja', 'javascript', 'sql']

    " auto select the first result when using 'longest'
    "let g:SuperTabLongestHighlight = 1 " triggers bug with single match (https://github.com/ervandew/supertab/commit/e026bebf1b7113319fc7831bc72d0fb6e49bd087#commitcomment-297471)

    " let g:SuperTabLongestEnhanced = 1  " involves mappings; requires
    " completeopt =~ longest
    let g:SuperTabClosePreviewOnPopupClose = 1

    " map <c-space> to <c-p> completion (useful when supertab 'context'
    " defaults to something else).
    " imap <nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-p>")<cr>

    au FileType python
      \ if &completefunc != '' |
      \   call SuperTabChain(&completefunc, "<c-p>") |
      \ endif
  endif
" }}}

let g:LustyExplorerSuppressRubyWarning = 1 " suppress warning when vim-ruby is not installed

" use for encryption:
" openssl enc -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd > 1
" openssl enc -d -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd < 1
let g:pastebin_api_dev_key = '95d8fa0dd25e7f8b924dd8103af42218'

let g:EclimLargeFileEnabled = 0
let g:EclimCompletionMethod = 'omnifunc' " setup &omnifunc instead of &completefunc; this way YCM picks it up
" let g:EclimLogLevel = 6
" if exists(":EclimEnable")
"   au VimEnter * EclimEnable
" endif
let g:EclimShowCurrentError = 0 " can be really slow, when used with PHP omnicompletion. I am using Syntastic anyway.
let g:EclimSignLevel = 0
let g:EclimLocateFileNonProjectScope = 'ag'
" Disable eclim's validation, prefer Syntastic.
" NOTE: patch pending to do so automatically (in eclim).
" does not work as expected, ref: https://github.com/ervandew/eclim/issues/199
let g:EclimFileTypeValidate = 0


" lua {{{
let g:lua_check_syntax = 0  " done via syntastic
" }}}

" Prepend <leader> to visualctrlg mappings.
let g:visualctrg_no_default_keymappings = 1
silent! vmap <unique> <Leader><C-g>  <Plug>(visualctrlg-briefly)
silent! vmap <unique> <Leader>g<C-g> <Plug>(visualctrlg-verbosely)

" Toggle quickfix window, using <Leader>qq. {{{2
" Based on: http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
nnoremap <Leader>qq :QFix<CR>
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
  au!
  au BufWinEnter quickfix let g:qfix_buf = bufnr("%")
augroup END
" 2}}}

" Adjust height of quickfix window {{{2
" Based on http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
au FileType qf call AdjustWindowHeight(1, 10)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
" function! AdjustWindowHeight(minheight, maxheight)
"   let totallines = line('$')
"   if totallines >= a:maxheight
"     n_lines = a:maxheight
"   else
"     let l = 1
"     let n_lines = 0
"     let w_width = winwidth(0)
"     while l <= totallines && n_lines < a:maxheight
"       " number to float for division
"       let l_len = strlen(getline(l)) + 0.0
"       let line_width = l_len/w_width
"       let n_lines += float2nr(ceil(line_width))
"       let l += 1
"     endw
"   endif
"   exe max([min([n_lines, a:maxheight]), a:minheight]) . "wincmd _"
" endfunction
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

" swap n_CTRL-Z and n_CTRL-Y (qwertz layout; CTRL-Z should be next to CTRL-U)
nnoremap <C-z> <C-y>
nnoremap <C-y> <C-z>

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
noremap <F2> g<C-]>
" expand abbr (insert mode and command line)
noremap! <F2> <C-]>
noremap <F3> :if exists('g:tmru#world')<cr>:let g:tmru#world.restore_from_cache = []<cr>:endif<cr>:TRecentlyUsedFiles<cr>
noremap <S-F3> :if exists('g:tmru#world')<cr>:let g:tmru#world.restore_from_cache = ['filter']<cr>:endif<cr>:TRecentlyUsedFiles<cr>
" XXX: mapping does not work (autoclose?!)
" noremap <F3> :CtrlPMRUFiles
fun! MyRefresh()
  if &diff
    diffupdate
  endif
endfun
noremap <F5> :call MyRefresh()<cr>
noremap <Leader>u :GundoToggle<cr>
" if has('gui_running')
"   map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>
"   imap <silent> <F11> <Esc><F11>a
" endif

" Mappings for german keyboard layout {{{
" Map ö/ä to brackets used by unimpaired (more accessible on a German keyboard layout)
map ö [
map ä ]
" For single hand mode:
nmap äj :exec (getloclist(0) ? ':lnext' : ':cnext')."<CR>"
nmap äk :exec (getloclist(0) ? ':lprev' : ':cprev')."<CR>"

" Quit with ää / exit with ÄÄ
nnoremap ÄÄ :confirm qall<cr>
nnoremap ää :confirm q<cr>

" Fast navigation.
map ü {
map + }
" }}}

" tagbar plugin
nnoremap <silent> <F8> :TagbarToggle<CR>
nnoremap <silent> <Leader><F8> :TagbarOpenAutoClose<CR>

" NERDTree {{{
" Show hidden files *except* the known temp files, system files & VCS files
let NERDTreeHijackNetrw = 0
let NERDTreeShowHidden = 1
let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor
let NERDTreeIgnore += ['^\.bundle$', '^\.bzr$', '^\.git$', '^\.hg$', '^\.sass-cache$', '^\.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']
let NERDTreeIgnore += ['__pycache__', '.ropeproject']
" }}}

" Smart way to move btw. windows {{{2
" (use cursor keys to not overwrite C-l (redraw))
map <C-Down> <C-W>j
map <C-Up> <C-W>k
map <C-Left> <C-W>h
map <C-Right> <C-W>l

" TODO
" noremap <Up> gk
" noremap <Down> gj
" (Cursor keys should be consistent between insert and normal mode)
" slow!
" inoremap <Up> <C-O>:normal gk<CR>
" inoremap <Down> <C-O>:normal gj<CR>
"
" j,k move by screen line instead of file line.
nnoremap j gj
nnoremap k gk
" inoremap <Down> <C-o>gj
" inoremap <Up> <C-o>gk
" XXX: does not keep virtual column! Also adds undo points!
" inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"
" inoremap <expr> <Up>   pumvisible() ? "\<C-p>" : "\<C-o>gk"

" Make C-BS and C-Del work like they do in most text editors for the sake of muscle memory {{{2
imap <C-BS> <C-W>
imap <C-Del> <C-O>dw
imap <C-S-Del> <C-O>dW
nmap <C-Del> dw
nmap <C-S-Del> dWa

" Map delete to 'delete to black hole register' (experimental, might use
" `d` instead)
" Join lines, if on last column, delete otherwise (used in insert mode)
" NOTE: de-activated: misbehaves with '""' at end of line (autoclose),
"       and deleting across lines works anyway. The registers also do not
"       get polluted.. do not remember why I came up with it...
" function! MyDelAcrossEOL()
"   echomsg col(".") col("$")
"   if col(".") == col("$")
"     " XXX: found no way to use '_' register
"     call feedkeys("\<Down>\<Home>\<Backspace>")
"   else
"     normal! "_x
"   endif
"   return ''
" endfunction
" noremap  <Del> "_<Del>
" inoremap <Del> <C-R>=MyDelAcrossEOL()<cr>
" vnoremap <Del> "_<Del>

" " Vaporize delete without overwriting the default register. {{{1
" nnoremap vd "_d
" xnoremap x "_d
" nnoremap vD "_D
" }}}

" Replace without yank {{{
" Source: https://github.com/justinmk/config/blob/master/.vimrc#L743
func! s:replace_without_yank(type)
  let sel_save = &selection
  let l:col = col('.')
  let &selection = "inclusive"

  if a:type == 'line'
    silent normal! '[V']"_d
  elseif a:type == 'block'
    silent normal! `[`]"_d
  else
    silent normal! `[v`]"_d
  endif

  if col('.') == l:col "paste to the left.
    silent normal! P
  else "if the operation deleted the last column, then the cursor
"gets bumped left (because its original position no longer exists),
"so we need to paste to the right instead of the left.
    silent normal! p
  endif

  let &selection = sel_save
endf
nnoremap <silent> rr :<C-u>set opfunc=<sid>replace_without_yank<CR>g@
nnoremap <silent> rrr 0:<C-u>set opfunc=<sid>replace_without_yank<CR>g@$
" }}}
map _  <Plug>(operator-replace)


function! TabIsEmpty()
  return winnr('$') == 1 && WindowIsEmpty()
endfunction

" Is the current window considered to be empty?
function! WindowIsEmpty()
  if &ft == 'startify'
    return 1
  endif
  return len(expand('%')) == 0 && line2byte(line('$') + 1) <= 2
endfunction

function! MyEditConfig(path, ...)
  let cmd = a:0 ? a:1 : 'split'
  exec (WindowIsEmpty() ? 'e' : cmd) a:path
endfunction

" edit vimrc shortcut
" nnoremap <leader>ec <C-w><C-s><C-l>:exec "e ".resolve($MYVIMRC)<cr>
nnoremap <leader>ec :let sshm=&shm \| set shm+=A \| call MyEditConfig(resolve($MYVIMRC)) \| let &shm = sshm<cr>
nnoremap <leader>Ec :let sshm=&shm \| set shm+=A \| call MyEditConfig(resolve($MYVIMRC), 'vsplit') \| let &shm = sshm<cr>
" edit zshrc shortcut
nnoremap <leader>ez :call MyEditConfig(resolve("~/.zshrc"))<cr>
" edit tmux shortcut
nnoremap <leader>et :call MyEditConfig(resolve("~/.tmux.common.conf"))<cr>
" edit .lvimrc shortcut (in repository root)
nnoremap <leader>elv :call MyEditConfig(ProjectRootGuess().'/.lvimrc')<cr>

" Utility functions to create file commands
" Source: https://github.com/carlhuda/janus/blob/master/gvimrc
" function! s:CommandCabbr(abbreviation, expansion)
"   execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
" endfunction

" Open URL
nmap <leader>gw <Plug>(openbrowser-smart-search)
vmap <leader>gw <Plug>(openbrowser-smart-search)

" Remap CTRL-W_ using maximize.vim (smarter and toggles).
" NOTE: using `Ctrl-W o` currently mainly (via ZoomWin).
map <c-w>_ :MaximizeWindow<cr>

" vimdiff current vs git head (fugitive extension) {{{2
" Close any corresponding fugitive diff buffer.
function! MyCloseDiff()
  if (&diff == 0 || getbufvar('#', '&diff') == 0)
        \ && (bufname('%') !~ '^fugitive:' && bufname('#') !~ '^fugitive:')
    echom "Not in diff view."
    return
  endif

  diffoff " safety net / required to workaround powerline issue

  " Close current buffer if alternate is not fugitive but current one is.
  if bufname('#') !~ '^fugitive:' && bufname('%') =~ '^fugitive:'
    if bufwinnr("#") == -1
      " XXX: might not work reliable (old comment)
      b #
      bd #
    else
      bd
    endif
  else
    bd #
  endif
endfunction
" nnoremap <Leader>gd :Gdiff<cr>

" Maps related to version control (Git). {{{1
" Toggle `:Gdiff`.
nnoremap <Leader>gd :if !&diff \| Gdiff \| else \| call MyCloseDiff() \| endif <cr>
nnoremap <Leader>gD :call MyCloseDiff()<cr>
nnoremap <Leader>gc :Gcommit -v
" }}}1


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

" Capture output of a:cmd into a new tab via redirection
" source: http://vim.wikia.com/wiki/Capture_ex_command_output
function! RedirCommand(cmd, newcmd)
  " Default to "message" for command
  if empty(a:cmd) | let cmd = 'message' | else | let cmd = a:cmd | endif
  redir => message
    silent execute cmd
  redir END
  exec a:newcmd
  silent put=message
  " NOTE: 'ycmblacklisted' filetype used with YCM blacklist.
  "	      Needs patch: https://github.com/Valloric/YouCompleteMe/pull/830
  set nomodified ft=vim.ycmblacklisted
endfunction
command! -nargs=* -complete=command Redir call RedirCommand(<q-args>, 'tabnew')
" cnoreabbrev TM TabMessage
command! -nargs=* -complete=command Redirbuf call RedirCommand(<q-args>, 'new')
command! Maps Redir map

fun! Cabbrev(key, value)
  exe printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
    \ a:key, 1+len(a:key), string(a:value), string(a:key))
endfun
" IDEA: requires expansion of abbr.
call Cabbrev('/',   '/\v')
call Cabbrev('?',   '?\v')
call Cabbrev('s/',  's/\v')
call Cabbrev('%s/', '%s/\v')

" Swap ' and ` keys (` is more useful, but requires shift on a German keyboard) {{{2
noremap ' `
sunmap '
noremap ` '
sunmap `
noremap g' g`
sunmap g'
noremap g` g'
sunmap g`

" Make Y consistent with C and D / copy selection to gui-clipboard. {{{2
nnoremap Y y$
" copy selection to gui-clipboard
xnoremap Y "+y

" Cycle history.
cnoremap <c-j> <up>
cnoremap <c-k> <down>

" Idea: change the xterm cursor color for insert mode {{{2
if &term =~? '^xterm' && exists('&t_SI') && &t_Co > 1
  " let &t_SI="\<Esc>]12;purple\x7"
  " let &t_EI="\<Esc>]12;green\x7"
endif

" Folding {{{2
if has("folding")
  set foldenable
  set foldmethod=marker

  " set foldmethod=syntax
  " let javaScript_fold=1         " JavaScript
  " javascript:
  au! FileType javascript syntax region foldBraces start=/{/ end=/}/ transparent fold keepend extend | setlocal foldmethod=syntax

  " let perl_fold=1               " Perl
  " let php_folding=1             " PHP
  " let r_syntax_folding=1        " R
  " let ruby_fold=1               " Ruby
  " let sh_fold_enabled=1         " sh
  " let vimsyn_folding='af'       " Vim script
  " let xml_syntax_folding=1      " XML

  set foldlevel=1
  set foldlevelstart=1

  " set foldmethod=indent
  " set foldnestmax=2
  " set foldtext=strpart(getline(v:foldstart),0,50).'\ ...\ '.substitute(getline(v:foldend),'^[\ #]*','','g').'\ '

  " set foldcolumn=2
  " <2-LeftMouse>     Open fold, or select word or % match.
  nnoremap <expr> <2-LeftMouse> foldclosed(line('.')) == -1 ? "\<2-LeftMouse>" : 'zo'
endif

if has('eval')
  " Windo/Bufdo/Tabdo which do not change window, buffer or tab. {{{1
  " Source: http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers#Restoring_position
  " Like windo but restore the current window.
  function! WinDo(command)
    let currwin=winnr()
    execute 'windo ' . a:command
    execute currwin . 'wincmd w'
  endfunction
  com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

  " Like bufdo but restore the current buffer.
  function! BufDo(command)
    let currBuff=bufnr("%")
    execute 'bufdo ' . a:command
    execute 'buffer ' . currBuff
  endfunction
  com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

  " Like tabdo but restore the current tab.
  function! TabDo(command)
    let currTab=tabpagenr()
    execute 'tabdo ' . a:command
    execute 'tabn ' . currTab
  endfunction
  com! -nargs=+ -complete=command Tabdo call TabDo(<q-args>)
  " }}}1

  " Maps for fold commands across windows.
  for k in ['i', 'm', 'M', 'n', 'N', 'r', 'R', 'v', 'x', 'X']
    execute "nnoremap <silent> Z".k." :Windo normal z".k."<CR>"
  endfor
endif

if has('user_commands')
  " typos
  command! -bang Q q<bang>
  command! W w
  command! Wq wq
  command! Wqa wqa
endif

"{{{2 Abbreviations
" <C-g>u adds break to undo chain, see i_CTRL-G_u
iabbr cdata <![CDATA[]]><Left><Left><Left>
iabbr sg  Sehr geehrte Damen und Herren,<cr>
iabbr sgh Sehr geehrter Herr<space>
iabbr sgf Sehr geehrte Frau<space>
iabbr mfg Mit freundlichen Grüßen,<cr><C-g>u<C-r>=g:my_full_name<cr>
iabbr LG Liebe Grüße,<cr>Daniel.
iabbr VG Viele Grüße,<cr>Daniel.
" ellipsis
abbr ... …
" sign "checkmark"
iabbr scm ✓
iabbr <expr> dts strftime('%a, %d %b %Y %H:%M:%S %z')
iabbr dtsf <C-r>=strftime('%a, %d %b %Y %H:%M:%S %z')<cr><space>{{{<cr><cr>}}}<up>
" German/styled quotes.
iabbr <silent> _" „“<Left>
iabbr <silent> _' ‚‘<Left>
iabbr <silent> _- –<space>
"}}}

" ignore certain files for completion (used also by Command-T)
" TODO: merge with &suffixes?!
set wildignore+=*.o,*.obj,.git,.svn
set wildignore+=*.png,*.jpg,*.jpeg,*.gif,*.mp3
set wildignore+=*.sw?
set wildignore+=*.pyc
set wildignore+=__pycache__
if has('wildignorecase') " not on MacOS
  set wildignorecase
endif

" allow for tab-completion in vim, but ignore them with command-t
let g:CommandTWildIgnore=&wildignore . ",**/bower_components/*"
      \ .',htdocs/asset/**'
      \ .',htdocs/media/**'
      \ .',static/_build/**'
      \ .',**/node_modules/**'

let g:vdebug_keymap = {
\    "run" : "<S-F5>",
\}
command! VdebugStart python debugger.run()

" LocalVimRC {{{
let g:localvimrc_sandbox = 0 " allow to adjust/set &path
let g:localvimrc_persistent = 1 " 0=no, 1=uppercase, 2=always
let g:localvimrc_debug = 0
let g:localvimrc_persistence_file = g:vimsharedir . '/localvimrc_persistent'

" Helper method for .lvimrc files to finish
fun! MyLocalVimrcAlreadySourced(...)
  " let sfile = expand(a:sfile)
  let sfile = g:localvimrc_script
  let guard_key = expand(sfile).getftime(sfile)
  if exists('b:local_vimrc_sourced')
    if type(b:local_vimrc_sourced) != type({})
      echomsg "warning: b:local_vimrc_sourced is not a dict!"
      let b:local_vimrc_sourced = {}
    endif
    if has_key(b:local_vimrc_sourced, guard_key)
      return 1
    endif
  else
    let b:local_vimrc_sourced = {}
  endif
  let b:local_vimrc_sourced[guard_key] = 1
  return 0
endfun
" }}}

" vim-session / session.vim {{{
" Do not autoload/autosave 'default' session
" let g:session_autoload = 'no'
" let g:session_autosave = 'no'
let g:session_command_aliases = 1
let g:session_persist_globals = [
      \ 'g:tmru_file',
      \ 'g:session_autosave',
      \ 'g:MySessionName']
" call add(g:session_persist_globals, 'g:session_autoload')

" fun! MyOnVimEnter()
"   let sname = v:servername
"   if ! MyIsGlobalVimServer()
"     " TODO: use another viminfo file (via 'n' option).
"
"     " Use existing tmru_file (gets remembered across sessions).
"     if v:servername && filereadable(g:tmru_file.'_'.v:servername)
"       let g:tmru_file = g:tmru_file . '_' . sname
"     endif
"   endif
"     if v:servername && filereadable(g:tmru_file.'_'.v:servername)
" endfun
" au VimEnter * call MyOnVimEnter()
" }}}

" xmledit: do not enable for HTML (default)
" interferes too much, see issue https://github.com/sukima/xmledit/issues/27
" let g:xmledit_enable_html = 1

" indent these tags for ft=html
let g:html_indent_inctags = "body,html,head,p,tbody"
" do not indent these
let g:html_indent_autotags = "br,input"


" better-whitespace: disable by default.
" TODO: DisableWhitespace is buggy across buffers?!
let g:better_whitespace_enabled = 0
nmap <Leader>sw :ToggleWhitespace<cr>
augroup MyBetterWhitespace
  au!
  au FileType * if &buftype == 'nofile' | exec 'DisableWhitespace' | endif
  au FileType diff,gitcommit DisableWhitespace
augroup END


" Setup late autocommands {{{
if has('autocmd')"
  augroup vimrc_late
    au!
    au FileType mail let b:no_detect_indent=1
    au BufReadPost * if exists(':DetectIndent') | if ! exists('b:no_detect_indent') || empty(b:no_detect_indent) | exec 'DetectIndent' | endif | endif

    au BufReadPost * if &bt == "quickfix" | set nowrap | endif

    " Check if the new file (with git-diff prefix removed) is readable and
    " edit that instead (copy'n'paste from shell)
    au BufNewFile * nested let s:fn = expand('<afile>') | if ! filereadable(s:fn) | let s:fn = substitute(s:fn, '^[abiw]/', '', '') | if filereadable(s:fn) | echomsg 'Editing' s:fn 'instead' | exec 'e '.s:fn.' | bd#' | endif | endif

    " Display a warning when editing foo.css, but foo.{scss,sass} exists
    au BufRead *.css if glob(expand('<afile>:r').'.s[ca]ss', 1) != "" | echoerr "WARN: editing .css, but .scss/.sass exists!" | endif

    " Make Vim help files modifiable by default.
    au FileType help setl modifiable
  augroup END
endif " }}}


" delimitMate
" let g:delimitMate_balance_matchpairs = 1
" let g:delimitMate_expand_cr = 1
" let g:delimitMate_expand_space = 1
" au FileType c,perl,php let b:delimitMate_eol_marker = ";"
" (pre-)Override S-Tab mapping
" Orig: silent! imap <unique> <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "<Plug>delimitMateS-Tab"
" Ref: https://github.com/Raimondi/delimitMate/pull/148#issuecomment-29428335
imap <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "<Plug>delimitMateS-Tab"


" Fix xterm keys {{{
" Map alt sequences for terminal via Esc.
" source: http://stackoverflow.com/a/10216459/15690
" NOTE: <Esc>O is used for special keys (e.g. OF (End))
" NOTE: drawback (with imap) - triggers timeout for Esc: use jk/kj,
"       or press it twice.
" NOTE: Alt-<NR> mapped in tmux. TODO: change this?!
" NOTE: äd
if ! has('gui_running')
  fun! MySetupAltMapping(c)
    " exec "set <A-".a:c.">=\e".a:c
    " exec "imap \e".a:c." <A-".a:c.">"
    exec "nmap \e".a:c." <A-".a:c.">"
    " insert and command line mode:
    " exec "map! \e".a:c." <A-".a:c.">"
  endfun
  for [c, n] in items({'a':'z', 'A':'N', 'P':'Z', '0':'9'})
    while 1
      call MySetupAltMapping(c)
      if c >= n
        break
      endif
      let c = nr2char(1+char2nr(c))
    endw
  endfor
  for c in [',', '.', '-', 'ö', 'ä', '#', 'ü', '+', '<']
    call MySetupAltMapping(c)
  endfor
endif

" Setup <Esc><Esc> as a map to <Esc> to workout timeout.
" NOTE: mapping it to C-c is a bad idea, for leaving insert mode.
" NOTE: not for insert mode, where there shouldn't be a timeout (no imap for
"       Alt keys, ...)
" NOTE: makes <Esc><Up> problematic.
" noremap <Esc><Esc> <Esc>

" Map Shift-motion keys.
nmap <Esc>[1;2A <S-Up>
"map! <Esc>[1;2A <S-Up>
nmap <Esc>[1;2B <S-Down>
"map! <Esc>[1;2B <S-Down>
nmap <Esc>[1;2C <S-Right>
"map! <Esc>[1;2C <S-Right>
nmap <Esc>[1;2D <S-Left>
"map! <Esc>[1;2D <S-Left>
nmap <Esc>[1;2F <S-End>
"map! <Esc>[1;2F <S-End>
nmap <Esc>[1;2H <S-Home>
"map! <Esc>[1;2H <S-Home>
nmap <Esc>[2;2~ <S-Insert>
"map! <Esc>[2;2~ <S-Insert>
nmap <Esc>[3;2~ <S-Delete>
"map! <Esc>[3;2~ <S-Delete>
nmap <Esc>[5;2~ <S-PageUp>
"map! <Esc>[5;2~ <S-PageUp>
nmap <Esc>[6;2~ <S-PageDown>
"map! <Esc>[6;2~ <S-PageDown>

" Fix up M-motion keys
nmap <Esc>[1;3A <M-Up>
"map! <Esc>[1;3A <M-Up>
nmap <Esc>[1;3B <M-Down>
"map! <Esc>[1;3B <M-Down>
nmap <Esc>[1;3C <M-Right>
"map! <Esc>[1;3C <M-Right>
nmap <Esc>[1;3D <M-Left>
"map! <Esc>[1;3D <M-Left>
nmap <Esc>[1;3F <M-End>
"map! <Esc>[1;3F <M-End>
nmap <Esc>[1;3H <M-Home>
"map! <Esc>[1;3H <M-Home>
nmap <Esc>[2;3~ <M-Insert>
"map! <Esc>[2;3~ <M-Insert>
nmap <Esc>[3;3~ <M-Delete>
"map! <Esc>[3;3~ <M-Delete>
nmap <Esc>[5;3~ <M-PageUp>
"map! <Esc>[5;3~ <M-PageUp>
nmap <Esc>[6;3~ <M-PageDown>
"map! <Esc>[6;3~ <M-PageDown>

" Fix up S-M-motion keys
nmap <Esc>[1;4A <S-M-Up>
"map! <Esc>[1;4A <S-M-Up>
nmap <Esc>[1;4B <S-M-Down>
"map! <Esc>[1;4B <S-M-Down>
nmap <Esc>[1;4C <S-M-Right>
"map! <Esc>[1;4C <S-M-Right>
nmap <Esc>[1;4D <S-M-Left>
"map! <Esc>[1;4D <S-M-Left>
nmap <Esc>[1;4F <S-M-End>
"map! <Esc>[1;4F <S-M-End>
nmap <Esc>[1;4H <S-M-Home>
"map! <Esc>[1;4H <S-M-Home>
nmap <Esc>[2;4~ <S-M-Insert>
"map! <Esc>[2;4~ <S-M-Insert>
nmap <Esc>[3;4~ <S-M-Delete>
"map! <Esc>[3;4~ <S-M-Delete>
nmap <Esc>[5;4~ <S-M-PageUp>
"map! <Esc>[5;4~ <S-M-PageUp>
nmap <Esc>[6;4~ <S-M-PageDown>
"map! <Esc>[6;4~ <S-M-PageDown>

" Fix up C-motion keys
nmap <Esc>[1;5A <C-Up>
"map! <Esc>[1;5A <C-Up>
nmap <Esc>[1;5B <C-Down>
"map! <Esc>[1;5B <C-Down>
nmap <Esc>[1;5C <C-Right>
"map! <Esc>[1;5C <C-Right>
nmap <Esc>[1;5D <C-Left>
"map! <Esc>[1;5D <C-Left>
nmap <Esc>[1;5F <C-End>
"map! <Esc>[1;5F <C-End>
nmap <Esc>[1;5H <C-Home>
"map! <Esc>[1;5H <C-Home>
nmap <Esc>[2;5~ <C-Insert>
"map! <Esc>[2;5~ <C-Insert>
nmap <Esc>[3;5~ <C-Delete>
"map! <Esc>[3;5~ <C-Delete>
nmap <Esc>[5;5~ <C-PageUp>
"map! <Esc>[5;5~ <C-PageUp>
nmap <Esc>[6;5~ <C-PageDown>
"map! <Esc>[6;5~ <C-PageDown>

" Fix up S-C-motion keys
nmap <Esc>[1;6A <S-C-Up>
"map! <Esc>[1;6A <S-C-Up>
nmap <Esc>[1;6B <S-C-Down>
"map! <Esc>[1;6B <S-C-Down>
nmap <Esc>[1;6C <S-C-Right>
"map! <Esc>[1;6C <S-C-Right>
nmap <Esc>[1;6D <S-C-Left>
"map! <Esc>[1;6D <S-C-Left>
nmap <Esc>[1;6F <S-C-End>
"map! <Esc>[1;6F <S-C-End>
nmap <Esc>[1;6H <S-C-Home>
"map! <Esc>[1;6H <S-C-Home>
nmap <Esc>[2;6~ <S-C-Insert>
"map! <Esc>[2;6~ <S-C-Insert>
nmap <Esc>[3;6~ <S-C-Delete>
"map! <Esc>[3;6~ <S-C-Delete>
nmap <Esc>[5;6~ <S-C-PageUp>
"map! <Esc>[5;6~ <S-C-PageUp>
nmap <Esc>[6;6~ <S-C-PageDown>
"map! <Esc>[6;6~ <S-C-PageDown>

" Fix up M-C-motion keys
nmap <Esc>[1;7A <M-C-Up>
"map! <Esc>[1;7A <M-C-Up>
nmap <Esc>[1;7B <M-C-Down>
"map! <Esc>[1;7B <M-C-Down>
nmap <Esc>[1;7C <M-C-Right>
"map! <Esc>[1;7C <M-C-Right>
nmap <Esc>[1;7D <M-C-Left>
"map! <Esc>[1;7D <M-C-Left>
nmap <Esc>[1;7F <M-C-End>
"map! <Esc>[1;7F <M-C-End>
nmap <Esc>[1;7H <M-C-Home>
"map! <Esc>[1;7H <M-C-Home>
nmap <Esc>[2;7~ <M-C-Insert>
"map! <Esc>[2;7~ <M-C-Insert>
nmap <Esc>[3;7~ <M-C-Delete>
"map! <Esc>[3;7~ <M-C-Delete>
nmap <Esc>[5;7~ <M-C-PageUp>
"map! <Esc>[5;7~ <M-C-PageUp>
nmap <Esc>[6;7~ <M-C-PageDown>
"map! <Esc>[6;7~ <M-C-PageDown>

" Fix up S-M-C-motion keys
nmap <Esc>[1;8A <S-M-C-Up>
"map! <Esc>[1;8A <S-M-C-Up>
nmap <Esc>[1;8B <S-M-C-Down>
"map! <Esc>[1;8B <S-M-C-Down>
nmap <Esc>[1;8C <S-M-C-Right>
"map! <Esc>[1;8C <S-M-C-Right>
nmap <Esc>[1;8D <S-M-C-Left>
"map! <Esc>[1;8D <S-M-C-Left>
nmap <Esc>[1;8F <S-M-C-End>
"map! <Esc>[1;8F <S-M-C-End>
nmap <Esc>[1;8H <S-M-C-Home>
"map! <Esc>[1;8H <S-M-C-Home>
nmap <Esc>[2;8~ <S-M-C-Insert>
"map! <Esc>[2;8~ <S-M-C-Insert>
nmap <Esc>[3;8~ <S-M-C-Delete>
"map! <Esc>[3;8~ <S-M-C-Delete>
nmap <Esc>[5;8~ <S-M-C-PageUp>
"map! <Esc>[5;8~ <S-M-C-PageUp>
nmap <Esc>[6;8~ <S-M-C-PageDown>
"map! <Esc>[6;8~ <S-M-C-PageDown>
" }}}
fun! MyGetNonDefaultServername()
  " Not for gvim in general (uses v:servername by default), and the global
  " server ("G").
  let sname = v:servername
  if len(sname) && sname =~# '\v^GVIM.*' && sname =~# '\v^G\d*$'
    return sname
  endif
  return ''
endfun


" Local config (if any). {{{1
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif


" Local file settings. {{{1
" NOTE: no foldlevel=1, to make `zv` from AutojumpLastPosition work.
" vim: fdm=marker
