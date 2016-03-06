set nocompatible " This must be first, because it changes other options as a side effect.

scriptencoding utf-8

" A bit faster than $SHELL (zsh).
set shell=/bin/sh

" Profiling. {{{
if 1
fun! ProfileStart()
  let profile_file = '/tmp/vim.'.getpid().'.profile.txt'
  echom "Profiling into" profile_file
  exec 'profile start '.profile_file
  profile! file **
  profile  func *
endfun
if get(g:, 'profile')
  call ProfileStart()
endif
endif
" }}}


if 1 " has('eval') / `let` may not be available.
  fun! MyWarningMsg(msg)
    redraw
    echohl WarningMsg | echom a:msg | echohl None
  endfun

  " Try to init neobundle.
  try
    set rtp+=~/.vim/bundle/neobundle
    let s:bundles_path = expand('~/.vim/neobundles')
    call neobundle#begin(s:bundles_path)
    let s:use_neobundle = 1
  catch
    echom "NeoBundle not found, falling back to Pathogen!"
    echom "Error:" v:exception
    set rtp+=~/.vim/bundle/pathogen
    let s:use_neobundle = 0
    let s:bundles_path = expand('~/.vim/bundles')
  endtry
  let s:use_pathogen = !s:use_neobundle

  let s:has_ycm = len(glob(s:bundles_path.'/YouCompleteMe/third_party/ycmd/ycm_core.*'))
  let s:use_ycm = s:has_ycm

  " Light(er) setup?
  if exists('MyRcProfile')
    if MyRcProfile ==# 'email'
      " Used with External Editor addon for Thunderbird (~/bin/gvim-email).
      fun! MySetupForEmail()
        if exists('b:did_setup_spl_email')
          return
        endif
        let b:did_setup_spl_email=1
        let l:cursor = getcurpos()
        if !search('\v%<5l^(To:|Cc:|Bcc:).*\@(\.de)@!', 'n')
          " Only german recipients.
          set spl=de
        endif
        call setpos('.', l:cursor)
      endfun
      augroup VimRcEmail
        au!
        " Not for help windows.
        au FileType * if &bt == '' | call MySetupForEmail() | endif
      augroup END

      let MyRcProfile = 'light'
    endif
  else
    let MyRcProfile = 'default'
  endif

  if s:use_neobundle  " {{{
    filetype off

    let g:neobundle#enable_name_conversion = 1  " Use normalized names.
    let g:neobundle#default_options = {
          \ 'manual': { 'base': '~/.vim/bundle', 'type': 'nosync' },
          \ 'colors': { 'script_type' : 'colors' } }

    " Cache file: use it from tmp/tmpfs. {{{
    " This helps in case the default location might not be writable (r/o
    " bind-mount), and should be good for performance in general (apart from
    " the first run after reboot).
    let s:vim_cache = '/tmp/vim-cache-' . $USER
    if !isdirectory(s:vim_cache)
      call mkdir(s:vim_cache, "", 0700)
    endif

    let s:cache_key = '_rc'.g:MyRcProfile.'_tmux'.executable("tmux")
          \ .'_deoplete'.get(s:, 'use_deoplete', 0)
          \ .'_nvim'.has('nvim')
    " Remove any previous cache files.
    let s:neobundle_default_cache_file = neobundle#commands#get_default_cache_file()
    let g:neobundle#cache_file = s:neobundle_default_cache_file . s:cache_key
    if filereadable(s:neobundle_default_cache_file)
      call delete(s:neobundle_default_cache_file)
    endif
    if filereadable(g:neobundle#cache_file)
      call delete(g:neobundle#cache_file)
    endif
    let g:neobundle#cache_file = s:vim_cache.'/neobundle.cache'.s:cache_key
    " }}}

    if neobundle#load_cache($MYVIMRC)
      " NeoBundles list - here be dragons! {{{
      fun! MyNeoBundleWrapper(cmd_args, default, light)
        let lazy = g:MyRcProfile == "light" ? a:light : a:default
        if lazy == -1
          return
        endif
        if lazy
          exec 'NeoBundleLazy ' . a:cmd_args
        else
          exec 'NeoBundle ' . a:cmd_args
        endif
      endfun
      com! -nargs=+ MyNeoBundle call MyNeoBundleWrapper(<q-args>, 1, 1)
      com! -nargs=+ MyNeoBundleLazy call MyNeoBundleWrapper(<q-args>, 1, 1)

      com! -nargs=+ MyNeoBundleNeverLazy call MyNeoBundleWrapper(<q-args>, 0, 0)
      com! -nargs=+ MyNeoBundleNoLazyForDefault call MyNeoBundleWrapper(<q-args>, 0, 1)
      com! -nargs=+ MyNeoBundleNoLazyNotForLight call MyNeoBundleWrapper(<q-args>, 0, -1)

      if s:use_ycm
        MyNeoBundleNoLazyForDefault 'blueyed/YouCompleteMe' , {
              \ 'build': {
              \   'unix': './install.sh --clang-completer --system-libclang'
              \           .' || ./install.sh --clang-completer',
              \ },
              \ 'augroup': 'youcompletemeStart',
              \ 'autoload': { 'filetypes': ['c', 'vim'], 'commands': 'YcmCompleter' }
              \ }
      endif

      MyNeoBundleLazy 'davidhalter/jedi-vim', '', {
            \ 'directory': 'jedi',
            \ 'autoload': { 'filetypes': ['python'], 'commands': ['Pyimport'] }}

      " Generate NeoBundle statements from .gitmodules.
      " (migration from pathogen to neobundle).
      " while read p url; do \
      "   echo "NeoBundle '${url#*://github.com/}', { 'directory': '${${p##*/}%.url}' }"; \
      " done < <(git config -f .gitmodules --get-regexp 'submodule.vim/bundle/\S+.(url)' | sort)

      MyNeoBundle 'tpope/vim-abolish'
      MyNeoBundle 'mileszs/ack.vim'
      MyNeoBundle 'tpope/vim-afterimage'
      MyNeoBundleNoLazyForDefault 'ervandew/ag'
      MyNeoBundleNoLazyForDefault 'gabesoft/vim-ags'
      MyNeoBundleNoLazyForDefault 'blueyed/vim-airline'
      MyNeoBundle 'vim-scripts/bufexplorer.zip', { 'name': 'bufexplorer' }
      MyNeoBundleNoLazyForDefault 'blueyed/bufkill.vim'
      MyNeoBundle 'vim-scripts/cmdline-completion', {
            \ 'autoload': {'mappings': [['c', '<Plug>CmdlineCompletion']]}}
      MyNeoBundle 'kchmck/vim-coffee-script'
      MyNeoBundle 'chrisbra/colorizer'
            \, { 'autoload': { 'commands': ['ColorToggle'] } }
      MyNeoBundle 'chrisbra/vim-diff-enhanced'
            \, { 'autoload': { 'commands': ['CustomDiff', 'PatienceDiff'] } }
      MyNeoBundle 'chrisbra/vim-zsh', {
            \ 'autoload': {'filetypes': ['zsh']} }
      " MyNeoBundle 'lilydjwg/colorizer'
      MyNeoBundle 'JulesWang/css.vim'
      MyNeoBundleNoLazyForDefault 'ctrlpvim/ctrlp.vim'
      MyNeoBundleNoLazyForDefault 'JazzCore/ctrlp-cmatcher'

      MyNeoBundle 'mtth/cursorcross.vim'
            \, { 'autoload': { 'insert': 1, 'filetypes': 'all' } }
      MyNeoBundleLazy 'tpope/vim-endwise', {
            \ 'autoload': {'filetypes': ['lua','elixir','ruby','sh','zsh','vb','vbnet','aspvbs','vim','c','cpp','xdefaults','objc','matlab']} }
      MyNeoBundle 'blueyed/cyclecolor'
      MyNeoBundleLazy 'Raimondi/delimitMate'
            \, { 'autoload': { 'insert': 1, 'filetypes': 'all' }}
      " MyNeoBundleNeverLazy 'cohama/lexima.vim'
      " MyNeoBundleNoLazyForDefault 'raymond-w-ko/detectindent'
      MyNeoBundleNoLazyForDefault 'roryokane/detectindent'
      MyNeoBundleNoLazyForDefault 'tpope/vim-dispatch'
      MyNeoBundle 'jmcomets/vim-pony', { 'directory': 'django-pony' }
      MyNeoBundle 'xolox/vim-easytags', {
            \ 'autoload': { 'commands': ['UpdateTags'] },
            \ 'depends': [['xolox/vim-misc', {'name': 'vim-misc'}]]}
      MyNeoBundleNoLazyForDefault 'tpope/vim-eunuch'
      MyNeoBundleNoLazyForDefault 'tommcdo/vim-exchange'
      MyNeoBundle 'int3/vim-extradite'
      MyNeoBundle 'jmcantrell/vim-fatrat'
      MyNeoBundleNoLazyForDefault 'kopischke/vim-fetch'
      MyNeoBundle 'thinca/vim-fontzoom'
      MyNeoBundleNoLazyForDefault 'idanarye/vim-merginal'
      MyNeoBundle 'mkomitee/vim-gf-python'
      MyNeoBundle 'mattn/gist-vim', {
            \ 'depends': [['mattn/webapi-vim']]}
      MyNeoBundle 'jaxbot/github-issues.vim'
      MyNeoBundle 'gregsexton/gitv'
      MyNeoBundleNeverLazy 'jamessan/vim-gnupg'
      MyNeoBundle 'zhaocai/GoldenView.Vim'
      MyNeoBundle 'google/maktaba'
      MyNeoBundle 'blueyed/grep.vim'
      MyNeoBundle 'mbbill/undotree', {
            \ 'autoload': {'command_prefix': 'Undotree'}}
      MyNeoBundle 'tpope/vim-haml'
      MyNeoBundle 'nathanaelkane/vim-indent-guides'
      " MyNeoBundle 'ivanov/vim-ipython'
      " MyNeoBundle 'johndgiese/vipy'
      MyNeoBundle 'vim-scripts/keepcase.vim'
      " NOTE: sets eventsignore+=FileType globally.. use a own snippet instead.
      " NOTE: new patch from author.
      MyNeoBundleNoLazyForDefault 'vim-scripts/LargeFile'
      " MyNeoBundleNoLazyForDefault 'mhinz/vim-hugefile'
      " MyNeoBundle 'groenewege/vim-less'
      MyNeoBundleNoLazyForDefault 'embear/vim-localvimrc'
      MyNeoBundle 'xolox/vim-lua-ftplugin', {
            \ 'autoload': {'filetypes': 'lua'},
            \ 'depends': [['xolox/vim-misc', {'name': 'vim-misc'}]]}
      MyNeoBundle 'raymond-w-ko/vim-lua-indent', {
            \ 'autoload': {'filetypes': 'lua'}}

      MyNeoBundle 'vim-scripts/luarefvim'
      MyNeoBundleNoLazyForDefault 'sjbach/lusty'
      MyNeoBundle 'vim-scripts/mail.tgz', { 'name': 'mail', 'directory': 'mail_tgz' }
      MyNeoBundle 'tpope/vim-markdown'
      MyNeoBundle 'nelstrom/vim-markdown-folding'
            \, {'autoload': {'filetypes': 'markdown'}}

      MyNeoBundle 'Shougo/neomru.vim'
      MyNeoBundleLazy 'blueyed/nerdtree', {
            \ 'augroup' : 'NERDTreeHijackNetrw' }
      MyNeoBundle 'blueyed/nginx.vim'
      MyNeoBundleLazy 'tyru/open-browser.vim', {
            \ 'autoload': { 'mappings': '<Plug>(openbrowser' } }
      MyNeoBundle 'kana/vim-operator-replace'
      MyNeoBundleNoLazyForDefault 'kana/vim-operator-user'
      MyNeoBundle 'vim-scripts/pac.vim'
      MyNeoBundle 'mattn/pastebin-vim'
      MyNeoBundle 'tpope/vim-pathogen'
      MyNeoBundle 'shawncplus/phpcomplete.vim'
      MyNeoBundle '2072/PHP-Indenting-for-VIm', { 'name': 'php-indent' }
      MyNeoBundle 'greyblake/vim-preview'
      MyNeoBundleNoLazyForDefault 'tpope/vim-projectionist'
      MyNeoBundleNoLazyForDefault 'dbakker/vim-projectroot'
      " MyNeoBundle 'dbakker/vim-projectroot', {
      "       \ 'autoload': {'commands': 'ProjectRootGuess'}}
      MyNeoBundle 'fs111/pydoc.vim'
            \ , {'autoload': {'filetypes': ['python']} }
      MyNeoBundle 'alfredodeza/pytest.vim'
      MyNeoBundle '5long/pytest-vim-compiler'
            \ , {'autoload': {'filetypes': ['python']} }
      MyNeoBundle 'hynek/vim-python-pep8-indent'
            \ , {'autoload': {'filetypes': ['python']} }
      " MyNeoBundle 'Chiel92/vim-autoformat'
      "       \ , {'autoload': {'filetypes': ['python']} }
      MyNeoBundleNoLazyForDefault 'tomtom/quickfixsigns_vim'
      MyNeoBundleNoLazyForDefault 't9md/vim-quickhl'
      MyNeoBundle 'aaronbieber/vim-quicktask'
      MyNeoBundle 'tpope/vim-ragtag'
            \ , {'autoload': {'filetypes': ['html', 'smarty', 'php', 'htmldjango']} }
      MyNeoBundle 'tpope/vim-rails'
      MyNeoBundle 'vim-scripts/Rainbow-Parenthsis-Bundle'
      MyNeoBundle 'thinca/vim-ref'
      MyNeoBundle 'tpope/vim-repeat'
      MyNeoBundle 'inkarkat/runVimTests'
      " MyNeoBundleLazy 'tpope/vim-scriptease', {
      "       \ 'autoload': {'mappings': 'zS', 'filetypes': 'vim', 'commands': ['Runtime']} }
      MyNeoBundleNoLazyForDefault 'tpope/vim-scriptease'
      MyNeoBundle 'xolox/vim-session', {
            \  'autoload': {'commands': ['SessionOpen', 'OpenSession']}
            \, 'depends': [['xolox/vim-misc', {'name': 'vim-misc'}]]
            \, 'augroup': 'PluginSession' }
      " For PHP:
      " MyNeoBundle 'blueyed/smarty.vim', {
      "       \ 'autoload': {'filetypes': 'smarty'}}
      MyNeoBundleNeverLazy 'justinmk/vim-sneak'
      MyNeoBundle 'rstacruz/sparkup'
            \ , {'autoload': {'filetypes': ['html', 'htmldjango', 'smarty']}}
      MyNeoBundle 'tpope/vim-speeddating'
      MyNeoBundle 'AndrewRadev/splitjoin.vim'
      MyNeoBundleNoLazyForDefault 'AndrewRadev/undoquit.vim'

      MyNeoBundleNoLazyForDefault 'EinfachToll/DidYouMean'

      MyNeoBundleNoLazyForDefault 'mhinz/vim-startify'

      " After startify: https://github.com/mhinz/vim-startify/issues/33
      " NeoBundle does not keep the order in the cache though.. :/
      MyNeoBundleNoLazyForDefault 'tpope/vim-fugitive'
            \, {'augroup': 'fugitive'}

      MyNeoBundleNoLazyForDefault 'chrisbra/sudoedit.vim', {
            \ 'autoload': {'commands': ['SudoWrite', 'SudoRead']} }
      MyNeoBundleNoLazyForDefault 'ervandew/supertab'
      MyNeoBundleNoLazyForDefault 'tpope/vim-surround'
      MyNeoBundle 'kurkale6ka/vim-swap'
      MyNeoBundleNoLazyForDefault 'scrooloose/syntastic', {
            \ 'autoload': {'filetypes': ['lua', 'python', 'sh', 'zsh']} }
      " MyNeoBundleNoLazyForDefault "benekastah/neomake", {
      "       \ 'autoload': {'filetypes': ['c', 'lua', 'python', 'sh', 'zsh']} }
      MyNeoBundle 'vim-scripts/syntaxattr.vim'

      if executable("tmux")
        MyNeoBundle 'Keithbsmiley/tmux.vim', {
              \ 'name': 'syntax-tmux',
              \ 'autoload': {'filetypes': ['tmux']} }
        MyNeoBundleNoLazyForDefault 'blueyed/vim-tmux-navigator'
        MyNeoBundle 'wellle/tmux-complete.vim'
      endif

      " Dependency
      " MyNeoBundle 'godlygeek/tabular'
      MyNeoBundle 'junegunn/vim-easy-align'
            \ ,{ 'autoload': {'commands': ['EasyAlign']} }

      " Display registers with " / @ / CTRL-R.
      MyNeoBundleNoLazyForDefault 'junegunn/vim-peekaboo'

      MyNeoBundle 'majutsushi/tagbar'
      MyNeoBundle 'tpope/vim-tbone'
      MyNeoBundleNoLazyForDefault 'tomtom/tcomment_vim'

      " MyNeoBundle 'kana/vim-textobj-user'
      MyNeoBundleNoLazyForDefault 'kana/vim-textobj-function'
            \ ,{'depends': 'kana/vim-textobj-user'}
      MyNeoBundleNoLazyForDefault 'kana/vim-textobj-indent'
            \ ,{'depends': 'kana/vim-textobj-user'}
      MyNeoBundleNoLazyForDefault 'mattn/vim-textobj-url'
            \ ,{'depends': 'kana/vim-textobj-user'}
      MyNeoBundle 'bps/vim-textobj-python'
            \ ,{'depends': 'kana/vim-textobj-user',
            \   'autoload': {'filetypes': 'python'}}
      MyNeoBundleNoLazyForDefault 'inkarkat/argtextobj.vim', {'depends': ['tpope/vim-repeat', 'vim-scripts/ingo-library']}
      MyNeoBundleNoLazyForDefault 'vim-scripts/ArgsAndMore', {'depends': ['vim-scripts/ingo-library']}
      " MyNeoBundle 'kana/vim-textobj-django-template', 'fix'
      MyNeoBundle 'mjbrownie/django-template-textobjects'
      MyNeoBundle 'vim-scripts/parameter-text-objects'

      " paulhybryant/vim-textobj-path  " ap/ip (next path w/o basename), aP/iP (prev)
      " kana/vim-textobj-syntax  " ay/iy

      MyNeoBundle 'tomtom/tinykeymap_vim'
      MyNeoBundle 'tomtom/tmarks_vim'
      MyNeoBundleNoLazyForDefault 'tomtom/tmru_vim', { 'depends':
            \ [['tomtom/tlib_vim', { 'directory': 'tlib' }]]}
      MyNeoBundle 'vim-scripts/tracwiki'
      MyNeoBundle 'tomtom/ttagecho_vim'
      " UltiSnips cannot be set as lazy (https://github.com/Shougo/neobundle.vim/issues/335).
      MyNeoBundleNoLazyForDefault 'SirVer/ultisnips'
      " MyNeoBundle 'honza/vim-snippets'
      MyNeoBundleNoLazyForDefault 'blueyed/vim-snippets'
      MyNeoBundleNeverLazy 'tpope/vim-unimpaired'
      MyNeoBundle 'Shougo/unite-outline'
      MyNeoBundleNoLazyForDefault 'Shougo/unite.vim'
      MyNeoBundle 'vim-scripts/vcscommand.vim'
      MyNeoBundleLazy 'joonty/vdebug', {
            \ 'autoload': { 'commands': 'VdebugStart' }}
      MyNeoBundle 'vim-scripts/viewoutput'
      MyNeoBundleNoLazyForDefault 'Shougo/vimfiler.vim'
      MyNeoBundle 'xolox/vim-misc', { 'name': 'vim-misc' }

      MyNeoBundle 'tpope/vim-capslock'

      MyNeoBundle 'sjl/splice.vim'  " Sophisticated mergetool.
      " Enhanced omnifunc for ft=vim.
      MyNeoBundle 'c9s/vimomni.vim'

      let vimproc_updcmd = has('win64') ?
            \ 'tools\\update-dll-mingw 64' : 'tools\\update-dll-mingw 32'
      execute "MyNeoBundle 'Shougo/vimproc.vim'," . string({
            \ 'build' : {
            \     'windows' : vimproc_updcmd,
            \     'cygwin' : 'make -f make_cygwin.mak',
            \     'mac' : 'make -f make_mac.mak',
            \     'unix' : 'make -f make_unix.mak',
            \    },
            \    'autoload': {'commands': ['VimProcBang', 'VimProcRead'] }
            \ })

      MyNeoBundle 'inkarkat/VimTAP', { 'name': 'VimTAP' }
      " Try VimFiler instead; vinegar maps "." (https://github.com/tpope/vim-repeat/issues/19#issuecomment-59454216).
      " MyNeoBundle 'tpope/vim-vinegar'
      MyNeoBundle 'jmcantrell/vim-virtualenv'
            \, { 'autoload': {'commands': 'VirtualEnvActivate'} }
      MyNeoBundle 'tyru/visualctrlg.vim'
      MyNeoBundle 'nelstrom/vim-visual-star-search'
      MyNeoBundle 'mattn/webapi-vim'
      MyNeoBundle 'gcmt/wildfire.vim'
      MyNeoBundle 'sukima/xmledit'
      " Expensive on startup, not used much
      " (autoload issue: https://github.com/actionshrimp/vim-xpath/issues/7).
      MyNeoBundleLazy 'actionshrimp/vim-xpath', {
            \ 'autoload': {'commands': ['XPathSearchPrompt']}}
      MyNeoBundle 'guns/xterm-color-table.vim'
      MyNeoBundleNoLazyForDefault 'maxbrunsfeld/vim-yankstack'

      MyNeoBundle 'klen/python-mode'

      " MyNeoBundle 'chrisbra/Recover.vim'

      MyNeoBundle 'blueyed/vim-diminactive'

      " Previously disabled plugins (pathogen_disabled):

      MyNeoBundle 'MarcWeber/vim-addon-nix'
            \, {'name': 'nix', 'autoload': {'filetypes': ['nix']}
            \, 'depends': [
            \ ['MarcWeber/vim-addon-mw-utils', { 'directory': 'mw-utils' }],
            \ ['MarcWeber/vim-addon-actions', { 'directory': 'actions' }],
            \ ['MarcWeber/vim-addon-completion', { 'directory': 'completion' }],
            \ ['MarcWeber/vim-addon-goto-thing-at-cursor', { 'directory': 'goto-thing-at-cursor' }],
            \ ['MarcWeber/vim-addon-errorformats', { 'directory': 'errorformats' }],
            \ ]}

      MyNeoBundleLazy 'szw/vim-maximizer'
            \ , {'autoload': {'commands': 'MaximizerToggle'}}

      " Colorschemes.
      " MyNeoBundle 'vim-scripts/Atom',             '', 'colors', { 'name': 'colorscheme-atom' }
      " MyNeoBundle 'chriskempson/base16-vim',      '', 'colors', { 'name': 'colorscheme-base16' }
      " MyNeoBundle 'rking/vim-detailed',           '', 'colors', { 'name': 'colorscheme-detailed' }
      " MyNeoBundle 'nanotech/jellybeans.vim',      '', 'colors', { 'name': 'colorscheme-jellybeans' }
      " MyNeoBundle 'tpope/vim-vividchalk',         '', 'colors', { 'name': 'colorscheme-vividchalk' }
      " MyNeoBundle 'nielsmadan/harlequin',         '', 'colors', { 'name': 'colorscheme-harlequin' }
      " MyNeoBundle 'gmarik/ingretu',               '', 'colors', { 'name': 'colorscheme-ingretu' }
      " MyNeoBundle 'vim-scripts/molokai',          '', 'colors', { 'name': 'colorscheme-molokai' }
      " MyNeoBundle 'vim-scripts/tir_black',        '', 'colors', { 'name': 'colorscheme-tir_black' }
      " MyNeoBundle 'blueyed/xoria256.vim',         '', 'colors', { 'name': 'colorscheme-xoria256' }
      " MyNeoBundle 'vim-scripts/xterm16.vim',      '', 'colors', { 'name': 'colorscheme-xterm16' }
      " MyNeoBundle 'vim-scripts/Zenburn',          '', 'colors', { 'name': 'colorscheme-zenburn' }
      " MyNeoBundle 'whatyouhide/vim-gotham',       '', 'colors', { 'name': 'colorscheme-gotham' }

      " EXPERIMENTAL
      " MyNeoBundle 'atweiden/vim-betterdigraphs', { 'directory': 'betterdigraphs' }
      MyNeoBundle 'chrisbra/unicode.vim', { 'type__depth': 1 }

      MyNeoBundleNoLazyForDefault 'repeatable-motions.vim'

      MyNeoBundle 'xolox/vim-colorscheme-switcher'

      MyNeoBundle 't9md/vim-choosewin'

      MyNeoBundleNeverLazy 'junegunn/vim-oblique/', { 'depends':
            \ [['junegunn/vim-pseudocl']]}

      MyNeoBundle 'Konfekt/fastfold'

      MyNeoBundleNoLazyNotForLight 'junegunn/vader.vim', {
            \ 'autoload': {'commands': 'Vader'} }

      MyNeoBundleNoLazyForDefault 'ryanoasis/vim-webdevicons'

      MyNeoBundle 'mjbrownie/vim-htmldjango_omnicomplete'
            \ , {'autoload': {'filetypes': ['htmldjango']} }

      MyNeoBundle 'othree/html5.vim'
            \ , {'autoload': {'filetypes': ['html', 'htmldjango']} }

      MyNeoBundleLazy 'lambdalisue/vim-pyenv'
            " \ , {'depends': ['blueyed/YouCompleteMe']
            " \ ,  'autoload': {'filetypes': ['python', 'htmldjango']} }

      " Problems with <a-d> (which is ä), and I prefer <a-hjkl>.
      " MyNeoBundleNoLazyForDefault 'tpope/vim-rsi'


      MyNeoBundleLazy 'chase/vim-ansible-yaml'
            \ , {'autoload': {'filetypes': ['yaml', 'ansible']} }
      " MyNeoBundleLazy 'mrk21/yaml-vim'
      "       \ , {'autoload': {'filetypes': ['yaml', 'ansible']} }

      " Manual bundles.
      MyNeoBundle 'eclim', '', 'manual'

      " MyNeoBundle 'neobundle', '', 'manual'
      " NeoBundleFetch "Shougo/neobundle.vim", {
      "       \ 'default': 'manual',
      "       \ 'directory': 'neobundle', }


      MyNeoBundleNeverLazy 'blueyed/vim-colors-solarized', '', 'colors', { 'name': 'colorscheme-solarized' }
      " }}}
      NeoBundleSaveCache
    endif
    call neobundle#end()

    filetype plugin indent on

    " Use shallow copies by default.
    let g:neobundle#types#git#clone_depth = 10

    NeoBundleCheck

    if !has('vim_starting')
      " Call on_source hook when reloading .vimrc.
      call neobundle#call_hook('on_source')
    endif

  elseif s:use_pathogen
    set rtp+=~/.vim/bundle/pathogen
    filetype off

    let g:pathogen_disabled = [ 'golden-ratio', 'yankring' ]

    if ! s:use_ycm
      call add(g:pathogen_disabled, 'YouCompleteMe')
    else
      " call add(g:pathogen_disabled, 'supertab')
    endif

    let g:pathogen_disabled += [ "space" ]
    " nmap <unique> <Space> <Plug>SmartspaceNext
    " nmap <unique> <S-Space> <Plug>SmartspacePrev

    " Requires python
    if ! has('python') && ! has('python3')
      let g:pathogen_disabled += [ "jedi" ]
      let g:pathogen_disabled += [ "github-issues" ]
      let g:pathogen_disabled += [ "ultisnips" ]
      let g:pathogen_disabled += [ "xpath" ]
    endif

    " TO BE REMOVED"
    let g:pathogen_disabled += [ "shymenu" ]
    let g:pathogen_disabled += [ "easymotion" ]
    let g:pathogen_disabled += [ 'xpath' ]
    let g:pathogen_disabled += [ 'notes' ]  " XXX: needs writable path, not used currently
    let g:pathogen_disabled += [ "ipython" ]  " Not used, overwrites <C-s> by default

    call pathogen#infect()
  endif
endif

" Settings {{{1
set hidden
if &encoding != 'utf-8'  " Skip this on resourcing with Neovim (E905).
  set encoding=utf-8
endif
" Prefer unix fileformat
" set fileformat=unix
set fileformats=unix,dos

set backspace=indent,eol,start " allow backspacing over everything in insert mode
set confirm " ask for confirmation by default (instead of silently failing)
set nosplitright splitbelow
set diffopt+=vertical
set diffopt+=context:1000000  " don't fold
set history=1000
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching

set nowrapscan  " do not wrap around when searching.

set writebackup     " keep a backup while writing the file (default on)
set backupcopy=yes  " important to keep the file descriptor (inotify)

if 1  " has('eval'), and can create the dir dynamically.
  set directory=~/tmp/vim/swapfiles//  " // => use full path of original file
  set backup          " enable backup (default off), if 'backupdir' can be created dynamically.
endif

set noautoread  " Enabled by default in Neovim; I like to get notified/confirm it.

set nowrap

set autoindent    " always set autoindenting on (fallback after 'indentexpr')

set numberwidth=1  " Initial default, gets adjusted dynamically.

set tabstop=2
set shiftwidth=2
set noshiftround  " for `>`/`<` not behaving like i_CTRL-T/-D
set expandtab
set iskeyword+=-
if has('autocmd')
  augroup vimrc_iskeyword
    au!
    " Remove '-' and ':' from keyword characters (to highlight e.g. 'width:…' and 'font-size:foo' correctly)
    " XXX: should get fixed in syntax/css.vim probably!
    au FileType css setlocal iskeyword-=-:
  augroup END

  augroup VimrcColorColumn
    au!
    au ColorScheme * if expand("<amatch>") == "solarized" | set colorcolumn=78 | else | set colorcolumn= | endif
  augroup END
endif

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

if exists('+breakindent')
  set breakindent
  " set breakindentopt=min:20,shift:2,sbr
endif

set synmaxcol=1000  " don't syntax-highlight long lines (default: 3000)

set guioptions-=e  " Same tabline as with terminal (allows for setting colors).
set guioptions-=m  " no menu with gvim
set guioptions-=a  " do not mess with X selection when visual selecting text.
set guioptions+=A  " make modeless selections available in the X clipboard.

set viminfo+=% " remember opened files and restore on no-args start (poor man's crash recovery)
set viminfo+=! " keep global uppercase variables. Used by localvimrc.

set selectmode=
set mousemodel=popup " extend/popup/pupup_setpos
set keymodel-=stopsel " do not stop visual selection with cursor keys
set selection=inclusive
" set clipboard=unnamed
" Do not mess with X selection by default (only in modeless mode).
if !has('nvim')
  set clipboard-=autoselect
  set clipboard+=autoselectml
endif


if has('mouse')
  set mouse=nvi " Enable mouse (not for command line mode)

  if !has('nvim')
    " Make mouse work with Vim in tmux
    try
      set ttymouse=sgr
    catch
      set ttymouse=xterm2
    endtry
  endif
endif

set showmatch  " show matching pairs
set matchtime=3
" Jump to matching bracket when typing the closing one.
" Deactivated, causes keys to be ignored when typed too fast (?).
"inoremap } }<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ] ]<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a
"inoremap ) )<Left><c-o>%<c-o>:sleep 500m<CR><c-o>%<c-o>a

set sessionoptions+=unix,slash " for unix/windows compatibility
set nostartofline " do not go to start of line automatically when moving

" scrolloff: number of lines visible above/below the cursor.
" Special handling for &bt!="" and &diff.
set scrolloff=3
if has('autocmd')
  fun! MyAutoScrollOff() " {{{
    if exists('g:no_auto_scrolloff')
      return
    endif
    if &ft == 'help'
      let scrolloff = 999
    elseif &buftype != ""
      " Especially with quickfix (mouse jumping, more narrow).
      let scrolloff = 0
    elseif &diff
      let scrolloff = 10
    else
      let scrolloff = 3
    endif
    if &scrolloff != scrolloff
      let &scrolloff = scrolloff
    endif
  endfun
  augroup set_scrolloff
    au!
    au BufEnter,WinEnter * call MyAutoScrollOff()
    if exists('##TermOpen')  " neovim
      au TermOpen * set sidescrolloff=0 scrolloff=0
    endif
  augroup END
endif " }}}

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
  " Catch "Illegal character" (and its translations).
  catch /E539: /
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

" Generic mappings. {{{

" Use both , and Space as leader.
if 1  " has('eval')
  let mapleader = ","
endif
" Not for imap!
nmap <space> <Leader>
vmap <space> <Leader>

" Repeat last f/t in opposite direction.
if &rtp =~ '\<sneak\>'
  nmap <Leader>; <Plug>SneakPrevious
else
  nnoremap <Leader>; ,
endif

nnoremap <Leader><c-l> :redraw!<cr>
" Optimize mappings on German keyboard layout. {{{
" Maps initially inspired by the intl US keyboard layout.
" Not using langmap, because of bugs / issues, e.g.:
"  - used with input for LustyBufferGrep
" Not using a function to have this in minimal Vims, too.
" `sunmap` is used to use the key as-is in select mode.
map ö :
sunmap ö
map - /
sunmap -
map _ ?
sunmap _
map ü [
sunmap ü
map + ]
sunmap +

" TODO: ä

" Swap ' and ` keys (` is more useful, but requires shift on a German keyboard) {{{
noremap ' `
sunmap '
noremap ` '
sunmap `
noremap g' g`
sunmap g'
noremap g` g'
sunmap g`
" }}}


" Quit with Q, exit with C-q.
" (go to tab on the left).
fun! MyQuitWindow()
  let t = tabpagenr()
  let nb_tabs = tabpagenr('$')
  let was_last_tab = t == nb_tabs

  if &ft != 'qf'
    lclose
  endif
  confirm q

  if ! was_last_tab && nb_tabs != tabpagenr('$') && tabpagenr() > 1
    tabprevious
  endif
endfun
nnoremap <silent> Q :call MyQuitWindow()<cr>
nnoremap <silent> <C-Q> :confirm qall<cr>

" Use just "q" in special buffers.
if has('autocmd')
  augroup vimrc_special_q
    au!
    autocmd FileType help,startify nnoremap <buffer> q :confirm q<cr>
  augroup END
endif
" }}}


if 1 " has('eval') / `let` may not be available.
  " Close preview and quickfix windows.
  nnoremap <silent> <C-W>z :wincmd z<Bar>cclose<Bar>lclose<CR>

  let g:my_full_name = "Daniel Hahler"
  let g:snips_author = g:my_full_name

  " TAB is used by YouCompleteMe/SuperTab.
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

  " Sparkup (insert mode) maps. Default: <c-e>/<c-n>, both used by Vim.
  let g:sparkupExecuteMapping = '<Leader><c-e>'
  " '<c-n>' by default!
  let g:sparkupNextMapping = '<Leader><c-n>'

  " Syntastic {{{2
  let g:syntastic_enable_signs=1
  let g:syntastic_check_on_wq=1  " Only for active filetypes.
  let g:syntastic_auto_loc_list=1
  let g:syntastic_always_populate_loc_list=1
  " let g:syntastic_echo_current_error=0 " TEST: faster?!
  let g:syntastic_mode_map = {
        \ 'mode': 'passive',
        \ 'active_filetypes': ['ruby', 'php', 'lua', 'python', 'sh', 'zsh'],
        \ 'passive_filetypes': [] }
  let g:syntastic_error_symbol='✗'
  let g:syntastic_warning_symbol='⚠'
  let g:syntastic_aggregate_errors = 0
  let g:syntastic_python_checkers = ['python', 'frosted', 'flake8', 'pep8']

  " let g:syntastic_php_checkers = ['php']
  let g:syntastic_loc_list_height = 1 " handled via qf autocommand: AdjustWindowHeight

  " See 'syntastic_quiet_messages' and 'syntastic_<filetype>_<checker>_quiet_messages'
  " let g:syntastic_quiet_messages = {
  "       \ "level": "warnings",
  "       \ "type":  "style",
  "       \ "regex": '\m\[C03\d\d\]',
  "       \ "file":  ['\m^/usr/include/', '\m\c\.h$'] }
  let g:syntastic_quiet_messages = { "level": [], "type": ["style"] }

  fun! SyntasticToggleQuiet(k, v, scope)
    let varname = a:scope."syntastic_quiet_messages"
    if !exists(varname) | exec 'let '.varname.' = { "level": [], "type": ["style"] }' | endif
    exec 'let idx = index('.varname.'[a:k], a:v)'
    if idx == -1
      exec 'call add('.varname.'[a:k], a:v)'
      echom 'Syntastic: '.a:k.':'.a:v.' disabled (filtered).'
    else
      exec 'call remove('.varname.'[a:k], idx)'
      echom 'Syntastic: '.a:k.':'.a:v.' enabled (not filtered).'
    endif
  endfun
  command! SyntasticToggleWarnings call SyntasticToggleQuiet('level', 'warnings', "g:")
  command! SyntasticToggleStyle    call SyntasticToggleQuiet('type', 'style', "g:")
  command! SyntasticToggleWarningsBuffer call SyntasticToggleQuiet('level', 'warnings', "b:")
  command! SyntasticToggleStyleBuffer    call SyntasticToggleQuiet('type', 'style', "b:")

  fun! MySyntasticCheckAll()
    let save = g:syntastic_quiet_messages
    let g:syntastic_quiet_messages = { "level": [], 'type': [] }
    SyntasticCheck
    let g:syntastic_quiet_messages = save
  endfun
  command! MySyntasticCheckAll call MySyntasticCheckAll()

  " Source: https://github.com/scrooloose/syntastic/issues/1361#issuecomment-82312541
  function! SyntasticDisableToggle()
      if !exists('s:syntastic_disabled')
          let s:syntastic_disabled = 0
      endif
      if !s:syntastic_disabled
          let s:modemap_save = deepcopy(g:syntastic_mode_map)
          let g:syntastic_mode_map['active_filetypes'] = []
          let g:syntastic_mode_map['mode'] = 'passive'
          let s:syntastic_disabled = 1
          SyntasticReset
          echom "Syntastic disabled."
      else
          let g:syntastic_mode_map = deepcopy(s:modemap_save)
          let s:syntastic_disabled = 0
          echom "Syntastic enabled."
      endif
  endfunction
  command! SyntasticDisableToggle call SyntasticDisableToggle()

  " gist-vim {{{2
  let g:gist_detect_filetype = 1
  " }}}

  " tinykeymap: used to move between signs from quickfixsigns and useful by itself. {{{2
  let g:tinykeymap#mapleader = '<Leader>k'
  let g:tinykeymap#timeout = 0  " default: 5000s (ms)
  let g:tinykeymap#conflict = 1
  " Exit also with 'q'.
  let g:tinykeymap#break_key = 113
  " Default "*"; exluded "para_move" from tlib.
  " List: :echo globpath(&rtp, 'autoload/tinykeymap/map/*.vim')
  let g:tinykeymaps_default = [
        \ 'buffers', 'diff', 'filter', 'lines', 'loc', 'qfl', 'tabs', 'undo',
        \ 'windows', 'quickfixsigns',
        \ ]
        " \ 'para_move',
  " }}}

  " fontzoom {{{
  let g:fontzoom_no_default_key_mappings = 1
  nmap <A-+> <Plug>(fontzoom-larger)
  nmap <A--> <Plug>(fontzoom-smaller)
  " }}}

  " Call bcompare with current and alternate file.
  command! BC call system('bcompare '.shellescape(expand('%')).' '.shellescape(expand('#')).'&')


  " YouCompleteMe {{{
  " This needs to be the Python that YCM was built against.  (set in ~/.zshrc.local).
  if filereadable($PYTHON_YCM)
    let g:ycm_path_to_python_interpreter = $PYTHON_YCM
    " let g:ycm_path_to_python_interpreter = 'python-in-terminal'
  endif

  let g:ycm_filetype_blacklist = {
        \ 'python' : 1,
        \ 'ycmblacklisted': 1
        \}
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_collect_identifiers_from_comments_and_strings = 1
  let g:ycm_extra_conf_globlist = ['~/src/awesome/.ycm_extra_conf.py']

  " Jump mappings, overridden in Python mode with jedi-vim.
  nnoremap <leader>j :YcmCompleter GoToDefinition<CR>
  nnoremap <leader>gj :YcmCompleter GoToDeclaration<CR>
  fun! MySetupPythonMappings()
    nnoremap <buffer> <leader>j  :call jedi#goto_definitions()<CR>
    nnoremap <buffer> <leader>gj :call jedi#goto_assignments()<CR>
  endfun
  augroup vimrc_jump_maps
    au!
    au FileType python call MySetupPythonMappings()
  augroup END

  " Deactivated: causes huge RAM usage (YCM issue 595)
  " let g:ycm_collect_identifiers_from_tags_files = 1

  " EXPERIMENTAL: auto-popups and experimenting with SuperTab
  " NOTE: this skips the following map setup (also for C-n):
  "       ' pumvisible() ? "\<C-p>" : "\' . key .'"'
  let g:ycm_key_list_select_completion = []
  let g:ycm_key_list_previous_completion = []

  let g:ycm_semantic_triggers =  {
    \   'c' : ['->', '.'],
    \   'objc' : ['->', '.'],
    \   'ocaml' : ['.', '#'],
    \   'cpp,objcpp' : ['->', '.', '::'],
    \   'perl' : ['->'],
    \   'php' : ['->', '::'],
    \   'cs,java,javascript,d,vim,python,perl6,scala,vb,elixir,go' : ['.'],
    \   'ruby' : ['.', '::'],
    \   'lua' : ['.', ':'],
    \   'erlang' : [':'],
    \ }


  " Tags (configure this before easytags, except when using easytags_dynamic_files)
  " Look for tags file in parent directories, upto "/"
  set tags=./tags;/

  " CR and BS mapping: call various plugins manually. {{{
  let g:endwise_no_mappings = 1  " NOTE: must be unset instead of 0
  let g:cursorcross_no_map_CR = 1
  let g:cursorcross_no_map_BS = 1
  let g:delimitMate_expand_cr = 0
  let g:SuperTabCrMapping = 0  " Skip SuperTab CR map setup (skipped anyway for expr mapping)

  let g:cursorcross_mappings = 0  " No generic mappings for cursorcross.

  " Force delimitMate mapping (gets skipped if mapped already).
  fun! My_CR_map()
    " "<CR>" via delimitMateCR
    if len(maparg('<Plug>delimitMateCR', 'i'))
      let r = "\<Plug>delimitMateCR"
    else
      let r = "\<CR>"
    endif
    if len(maparg('<Plug>CursorCrossCR', 'i'))
      " requires vim 704
      let r .= "\<Plug>CursorCrossCR"
    endif
    if len(maparg('<Plug>DiscretionaryEnd', 'i'))
      let r .= "\<Plug>DiscretionaryEnd"
    endif
    return r
  endfun
  imap <expr> <CR> My_CR_map()

  fun! My_BS_map()
    " "<BS>" via delimitMateBS
    if len(maparg('<Plug>delimitMateBS', 'i'))
      let r = "\<Plug>delimitMateBS"
    else
      let r = "\<BS>"
    endif
    if len(maparg('<Plug>CursorCrossBS', 'i'))
      " requires vim 704
      let r .= "\<Plug>CursorCrossBS"
    endif
    return r
  endfun
  imap <expr> <BS> My_BS_map()

  " For endwise.
  imap <C-X><CR> <CR><Plug>AlwaysEnd
  " }}}

  " github-issues
  " Trigger API request(s) only when completion is used/invoked.
  let g:gissues_lazy_load = 1

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
  let g:PHP_autoformatcomment = 0 " do not set formatoptions/comments automatically (php-indent bundle / vim runtime)
  let g:php_noShortTags = 1

  " always use Smarty comments in smarty files
  " NOTE: for {php} it's useful
  let g:tcommentGuessFileType_smarty = 0
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

let s:check_create_dirs = [vimcachedir, g:tlib_cache, g:Powerline_cache_dir, vimconfigdir, g:session_directory, vimsharedir, &directory]

if has('persistent_undo')
  let &undodir = vimsharedir . '/undo'
  set undofile
  call add(s:check_create_dirs, &undodir)
endif

for s:create_dir in s:check_create_dirs
  " Remove trailing slashes, especially for &directory.
  let s:create_dir = substitute(s:create_dir, '/\+$', '', '')
  if ! isdirectory(s:create_dir)
    if match(s:create_dir, ',') != -1
      echohl WarningMsg | echom "WARN: not creating dir: ".s:create_dir | echohl None
      continue
    endif
    echom "Creating dir: ".s:create_dir
    call mkdir(s:create_dir, 'p', 0700 )
  endif
endfor
" }}}

if has("user_commands")
  " Themes
  " Airline:
  let g:airline#extensions#disable_rtp_load = 1
  let g:airline_powerline_fonts = 1
  " to test
  let g:airline#extensions#branch#use_vcscommand = 1
  let g:airline#extensions#branch#displayed_head_limit = 7

  let g:airline#extensions#hunks#non_zero_only = 1

  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#tabline#tab_nr_type = '[__tabnr__.%{len(tabpagebuflist(__tabnr__))}]'

  let g:airline#extensions#tmuxline#enabled = 1
  let g:airline#extensions#whitespace#enabled = 0

  let g:airline#extensions#tagbar#enabled = 0
  let g:airline#extensions#tagbar#flags = 'f'  " full hierarchy of tag (with scope), see tagbar-statusline
  " see airline-predefined-parts
  "   let r += ['%{ShortenFilename(fnamemodify(bufname("%"), ":~:."), winwidth(0)-50)}']
  " function! AirlineInit()
  "   "   let g:airline_section_a = airline#section#create(['mode', ' ', 'foo'])
  "   "   let g:airline_section_b = airline#section#create_left(['ffenc','file'])
  "   "   let g:airline_section_c = airline#section#create(['%{getcwd()}'])
  " endfunction
  " au VimEnter * call AirlineInit()

  " jedi-vim (besides YCM with jedi library) {{{1
  " let g:jedi#force_py_version = 3
  let g:jedi#auto_vim_configuration = 0
  let g:jedi#goto_assignments_command = ''  " dynamically done for ft=python.
  let g:jedi#goto_definitions_command = ''  " dynamically done for ft=python.
  let g:jedi#rename_command = 'cR'
  let g:jedi#usages_command = 'gr'
  let g:jedi#completions_enabled = 1

  " Unite/ref and pydoc are more useful.
  let g:jedi#documentation_command = '<Leader>_K'
  " Manually setup jedi's call signatures.
  let g:jedi#show_call_signatures = 1
  if &rtp =~ '\<jedi\>'
    augroup JediSetup
      au!
      au FileType python call jedi#configure_call_signatures()
    augroup END
  endif

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

  " Improved syntax handling of TODO etc.
  au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX):/
        \ containedin=.*Comment,vimCommentTitle
  hi def link MyTodo Todo
endif

if 1 " has('eval')
  " Color scheme (after 'syntax on') {{{1

  " Use light/dark background based on day/night period (according to
  " get-daytime-period (uses redshift))
  fun! SetBgAccordingToShell(...)
    let variant = a:0 ? a:1 : ""
    if len(variant) && variant != "auto"
      let bg = variant
    elseif len($TMUX)
      if system('tmux show-env MY_X_THEME_VARIANT') == "MY_X_THEME_VARIANT=light\n"
        let bg = 'light'
      else
        let bg = 'dark'
      endif
    else
      " let daytime = system('get-daytime-period')
      let daytime_file = expand('/tmp/redshift-period')
      if filereadable(daytime_file)
        let daytime = readfile(daytime_file)[0]
        if daytime == 'Daytime'
          let bg = "light"
        else
          let bg = "dark"
        endif
      else
        let bg = "dark"
      endif
    endif
    if bg != &bg
      let &bg = bg
    endif
  endfun
  command! Autobg call SetBgAccordingToShell()

  fun! ToggleBg()
    let &bg = &bg == 'dark' ? 'light' : 'dark'
  endfun
  nnoremap <Leader>sb :call ToggleBg()<cr>

  " Detect gnome-terminal. This is kind of obsolete with urxvt being the
  " default terminal now.
  fun! MyIsGnomeTerminal()
    if !exists('g:_MyIsGnomeTerminal')
      if len($COLORTERM)
        let g:_MyIsGnomeTerminal = ($COLORTERM == 'gnome-terminal')
      else
        let g:_MyIsGnomeTerminal = len(system('pstree -A -s $$ | grep -- -gnome-terminal-')) > 0
      endif
    endif
    return g:_MyIsGnomeTerminal
  endfun

  " Colorscheme: prefer solarized with 16 colors (special palette).
  let g:solarized_hitrail=0  " using MyWhitespaceSetup instead.

  " Use corresponding theme from $BASE16_THEME, if set up in the shell.
  " BASE16_THEME should be in sudoer's env_keep for "sudo vi".
  if len($BASE16_THEME)
    let base16colorspace=256
    if $BASE16_THEME =~ '^solarized'
      let s:use_colorscheme = 'solarized'
      let g:solarized_base16=1
      let g:airline_theme = 'base16'
    else
      let s:use_colorscheme = 'base16-'.substitute($BASE16_THEME, '\.\(dark\|light\)$', '', '')
    endif

  elseif has('gui_running')
    let s:use_colorscheme = "solarized"
    let g:solarized_termcolors=256

  else
    " Check for dumb terminal.
    if ($TERM !~ '256color' )
      let s:use_colorscheme = "default"
    else
      let s:use_colorscheme = "solarized"
      let g:solarized_termcolors=256
    endif
  endif

  " Airline: do not use powerline symbols with linux/screen terminal.
  " NOTE: xterm-256color gets setup for tmux/screen with $DISPLAY.
  if (index(["linux", "screen"], $TERM) != -1)
    let g:airline_powerline_fonts = 0
  endif

  fun! s:MySetColorscheme()
    " Set s:use_colorscheme, called through GUIEnter for gvim.
    try
      exec 'NeoBundleSource colorscheme-'.s:use_colorscheme
      exec 'colorscheme' s:use_colorscheme
    catch
      echom "Failed to load colorscheme: " v:exception
    endtry
  endfun

  if has('vim_starting')
    call SetBgAccordingToShell($MY_X_THEME_VARIANT)
  endif

  if has('gui_running')
    au GUIEnter * nested call s:MySetColorscheme()
  else
    call s:MySetColorscheme()
  endif
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd") " Autocommands {{{1
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
  " Handle large files, based on LargeFile plugin.
  let g:LargeFile = 5  " 5mb
  autocmd BufWinEnter * if get(b:, 'LargeFile_mode') || line2byte(line("$") + 1) > 1000000
        \ | echom "vimrc: handling large file."
        \ | set syntax=off
        \ | let &ft = &ft.".ycmblacklisted"
        \ | endif

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
    if &ft == 'help'
      return
    endif
    let fname = a:0 ? a:1 : expand('%')
    if fname =~ '^\w\+:/'
      " Do not mess with 'fugitive://' etc.
      return
    endif
    let fname = simplify(fname)

    let resolvedfile = resolve(fname)
    if resolvedfile == fname
      return
    endif
    let resolvedfile = fnameescape(resolvedfile)
    let sshm = &shm
    set shortmess+=A  " silence ATTENTION message about swap file (would get displayed twice)
    redraw  " Redraw now, to avoid hit-enter prompt.
    exec 'file ' . resolvedfile
    let &shm=sshm

    unlet! b:git_dir
    call fugitive#detect(resolvedfile)

    if &modifiable
      " Only display a note when editing a file, especially not for `:help`.
      redraw  " Redraw now, to avoid hit-enter prompt.
      echomsg 'Resolved symlink: =>' resolvedfile
    endif
  endfunction
  command! -bar FollowSymlink call MyFollowSymlink()
  command! ToggleFollowSymlink let w:no_resolve_symlink = !get(w:, 'no_resolve_symlink', 0) | echo "w:no_resolve_symlink =>" w:no_resolve_symlink
  au BufReadPost * nested call MyFollowSymlink(expand('%'))

  " Automatically load .vimrc source when saved
  au BufWritePost $MYVIMRC,~/.dotfiles/vimrc,$MYVIMRC.local source $MYVIMRC
  au BufWritePost $MYGVIMRC,~/.dotfiles/gvimrc source $MYGVIMRC

  " if (has("gui_running"))
  "   au FocusLost * stopinsert
  " endif

  " autocommands for fugitive {{{2
  " Source: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
  au User Fugitive
    \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)' |
    \   nnoremap <buffer> .. :edit %:h<CR> |
    \ endif
  au BufReadPost fugitive://* set bufhidden=delete

  " Expand tabs for Debian changelog. This is probably not the correct way.
  au BufNewFile,BufRead */debian/changelog,changelog.dch set expandtab

  " Ignore certain files with vim-stay.
  au BufNewFile,BufRead */.git/addp-hunk-edit.diff let b:stay_ignore = 1

  " Python
  " irrelevant, using python-pep8-indent
  " let g:pyindent_continue = '&sw * 1'
  " let g:pyindent_open_paren = '&sw * 1'
  " let g:pyindent_nested_paren = '&sw'

  " python-mode
  let g:pymode_options = 0              " do not change relativenumber
  let g:pymode_indent = 0               " use vim-python-pep8-indent (upstream of pymode)
  let g:pymode_lint = 0                 " prefer syntastic; pymode has problems when PyLint was invoked already before VirtualEnvActivate..!?!
  let g:pymode_virtualenv = 0           " use virtualenv plugin (required for pylint?!)
  let g:pymode_doc = 0                  " use pydoc
  let g:pymode_rope_completion = 0      " use YouCompleteMe instead (python-jedi)
  let g:pymode_syntax_space_errors = 0  " using MyWhitespaceSetup
  let g:pymode_trim_whitespaces = 0
  let g:pymode_debug = 0
  let g:pymode_rope = 0

  let g:pydoc_window_lines=0.5          " use 50% height
  let g:pydoc_perform_mappings=0

  " let python_space_error_highlight = 1  " using MyWhitespaceSetup


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
  au FileType make setlocal noexpandtab

  " Disable highlighting of markdownError (Ref: https://github.com/tpope/vim-markdown/issues/79).
  autocmd FileType markdown hi link markdownError NONE
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

" Statusline {{{

" Shorten a given (absolute) file path, via external `shorten_path` script.
" This mainly shortens entries from Zsh's `hash -d` list.
let s:_cache_shorten_path = {}
let s:_has_functional_shorten_path = 1
fun! ShortenPath(path, ...)
  if ! len(a:path) || ! s:_has_functional_shorten_path
    return a:path
  endif
  let base = a:0 ? a:1 : ""
  let cache_key = base . ":" . a:path
  if ! exists('s:_cache_shorten_path[cache_key]')
    try
      let tmpfile = tempname()
      let s:_cache_shorten_path[cache_key] = system('$HOME/.dotfiles/usr/bin/shorten_path '
            \ .shellescape(a:path).' '.shellescape(base).' 2>'.tmpfile)
      if v:shell_error
        echohl WarningMsg
        echom "There was a problem running shorten_path: "
              \ . join(readfile(tmpfile), "\n")
        echohl None
        let s:_has_functional_shorten_path = 0
      endif
    finally
      call delete(tmpfile)
    endtry
  endif
  return s:_cache_shorten_path[cache_key]
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
      if &bt != '' && len(&ft)
        " Use &ft for name (e.g. with 'startify' and quickfix windows).
        let alt_name = expand('#')
        if len(alt_name)
          return '['.&ft.'] '.ShortenFilename(expand('#'))
        else
          return '['.&ft.']'
        endif
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
  let cache_key = bufname.'::'.getcwd().'::'.maxlen
  if has_key(g:_cache_shorten_filename, cache_key)
    return g:_cache_shorten_filename[cache_key]
  endif

  " Make path relative first, which might not work with the result from
  " `shorten_path`.
  let rel_path = fnamemodify(bufname, ":.")
  let bufname = ShortenPath(rel_path, getcwd())
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
  if &modified
    let r .= ',+'
  endif
  return r
endfun
" }}}

" Setup custom "file" part for airline, using a buffer-local var for caching
" it (ref: https://github.com/bling/vim-airline/issues/658#issuecomment-64650886). {{{
if &rtp =~ '\<airline\>'
  " NOTE: does not work after writing with vim-gnupg (uses BufWriteCmd?!)
  fun! s:my_airline_clear_cache_file()
    if exists('b:my_airline_file_cache')
          \ && (!exists('b:my_airline_file_cache_key')
          \    || b:my_airline_file_cache_key != bufname('%').&modified.&ft)
      let b:my_airline_file_cache_key = bufname('%').&modified.&ft
      unlet! b:my_airline_file_cache
    endif
  endfun
  augroup vimrc_airline
    au!
    " Invalidate cache on certain events.  TextChanged* might not exist in older Vim.
    let s:autocmd = 'BufWritePost,BufEnter,CursorHold,InsertLeave,FileChangedShellPost'
    if exists('##TextChanged')
      let s:autocmd .= ",TextChanged,TextChangedI"
    endif
    exec 'au' s:autocmd '* call s:my_airline_clear_cache_file()'
  augroup END
  fun! ShortenFilenameForAirline()
    if exists('b:my_airline_file_cache')
      return b:my_airline_file_cache
    endif
    let b:my_airline_file_cache = ShortenFilenameWithSuffix()
    return b:my_airline_file_cache
  endfun
  call airline#parts#define_function('file', 'ShortenFilenameForAirline')
endif
" }}}

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

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
nnoremap <Leader>ee :e <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <Leader>EE :sp <C-R>=expand("%:p:h") . "/" <CR>

" gt: next tab or buffer (source: http://j.mp/dotvimrc)
"     enhanced to support range (via v:count)
fun! MyGotoNextTabOrBuffer(...)
  let c = a:0 ? a:1 : v:count
  exec (c ? c : '') . (tabpagenr('$') == 1 ? 'bn' : 'tabnext')
endfun
fun! MyGotoPrevTabOrBuffer()
  exec (v:count ? v:count : '') . (tabpagenr('$') == 1 ? 'bp' : 'tabprevious')
endfun
nnoremap <silent> <Plug>NextTabOrBuffer :<C-U>call MyGotoNextTabOrBuffer()<CR>
nnoremap <silent> <Plug>PrevTabOrBuffer :<C-U>call MyGotoPrevTabOrBuffer()<CR>

" Ctrl-Space: split into new tab.
" Disables diff mode, which gets taken over from the old buffer.
nnoremap <C-Space> :tab sp \| set nodiff<cr>
nnoremap <A-Space> :tabnew<cr>
" For terminal.
nnoremap <C-@> :tab sp \| set nodiff<cr>

" Opens a tab edit command with the path of the currently edited file filled in
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

map <a-o> <C-W>o
" Avoid this to be done accidentally (when zooming is meant). ":on" is more
" explicit.
map <C-W><C-o> <Nop>

" does not work, even with lilyterm.. :/
" TODO: <C-1>..<C-0> for tabs; not possible; only certain C-sequences get
" through to the terminal Vim
" nmap <C-Insert> :tabnew<cr>
" nmap <C-Del> :tabclose<cr>
nmap <A-Del> :tabclose<cr>
" nmap <C-1> 1gt<cr>

" Prev/next tab.
nmap <C-PageUp> <Plug>PrevTabOrBuffer
nmap <C-PageDown> <Plug>NextTabOrBuffer
map <A-,>     <Plug>PrevTabOrBuffer
map <A-.>     <Plug>NextTabOrBuffer
map <C-S-Tab> <Plug>PrevTabOrBuffer
map <C-Tab>   <Plug>NextTabOrBuffer

" Switch to most recently used tab.
" Source: http://stackoverflow.com/a/2120168/15690
fun! MyGotoMRUTab()
  if !exists('g:mrutab')
    let g:mrutab = 1
  endif
  if tabpagenr('$') == 1
    echomsg "There is only one tab!"
    return
  endif
  if g:mrutab > tabpagenr('$') || g:mrutab == tabpagenr()
    let g:mrutab = tabpagenr() > 1 ? tabpagenr()-1 : tabpagenr('$')
  endif
  exe "tabn ".g:mrutab
endfun
" Overrides Vim's gh command (start select-mode, but I don't use that).
" It can be simulated using v<C-g> also.
nnoremap gh  :call MyGotoMRUTab()<CR>
" nnoremap °  :call MyGotoMRUTab()<CR>
" nnoremap <C-^>  :call MyGotoMRUTab()<CR>
" nnoremap <tab><tab> :call MyGotoMRUTab()<CR>
augroup MyTL
  au!
  au TabLeave * let g:mrutab = tabpagenr()
augroup END

" Map <A-1> .. <A-9> to goto tab or buffer.
for i in range(9)
  exec 'nmap <M-' .(i+1).'> :call MyGotoNextTabOrBuffer('.(i+1).')<cr>'
endfor


fun! MyGetNonDefaultServername()
  " Not for gvim in general (uses v:servername by default), and the global
  " server ("G").
  let sname = v:servername
  if len(sname)
    if has('nvim')
      if sname !~# '^/tmp/nvim'
        let sname = substitute(fnamemodify(v:servername, ':t:r'), '^nvim-', '', '')
        return sname
      endif
    elseif sname !~# '\v^GVIM.*' " && sname =~# '\v^G\d*$'
      return sname
    endif
  endif
  return ''
endfun

fun! MyGetSessionName()
  " Use / auto-set g:MySessionName
  if !exists("g:MySessionName")
    if len(get(v:, 'this_session'))
      let g:MySessionName = fnamemodify(v:this_session, ':t:r')
    elseif len($TERM_INSTANCE_NAME)
      let g:MySessionName = substitute($TERM_INSTANCE_NAME, '^vim-', '', '')
    else
      let g:MySessionName = ''
    end
  endif
  return g:MySessionName
endfun

" titlestring handling, with tmux support {{{
" Set titlestring, used to set terminal title (pane title in tmux).
set title

" Setup titlestring on BufEnter, when v:servername is available.
fun! MySetupTitleString()
  let &titlestring = '✐ '

  let session_name = MyGetSessionName()
  if len(session_name)
    let &titlestring .= '['.session_name.'] '
  else
    " Add non-default servername to titlestring.
    let sname = MyGetNonDefaultServername()
    if len(sname)
      let &titlestring .= '['.sname.'] '
    endif
  endif

  " Call the function and use its result, rather than including it.
  " (for performance reasons).
  let &titlestring .= substitute(
        \ ShortenFilenameWithSuffix('%', 15).' ('.ShortenPath(getcwd()).')',
        \ '%', '%%', 'g')

  " Easier to type/find than the unicode symbol prefix.
  let &titlestring .= ' - vim'

  " Append $_TERM_TITLE_SUFFIX (e.g. user@host) to title (set via zsh, used
  " with SSH).
  if len($_TERM_TITLE_SUFFIX)
    let &titlestring .= $_TERM_TITLE_SUFFIX
  endif

  " Setup tmux window name, see ~/.dotfiles/oh-my-zsh/lib/termsupport.zsh.
  if len($TMUX)
        \ && (!len($_tmux_name_reset) || $_tmux_name_reset != $TMUX . '_' . $TMUX_PANE)
    let tmux_auto_rename=systemlist('tmux show-window-options -t '.$TMUX_PANE.' -v automatic-rename 2>/dev/null')
    " || $(tmux show-window-options -t $TMUX_PANE | grep '^automatic-rename' | cut -f2 -d\ )
    " echom string(tmux_auto_rename)
    if !len(tmux_auto_rename) || tmux_auto_rename[0] != "off"
      " echom "Resetting tmux name to 0."
      call system('tmux set-window-option -t '.$TMUX_PANE.' -q automatic-rename off')
      call system('tmux rename-window -t '.$TMUX_PANE.' 0')
    endif
  endif

  " Set icon text according to &titlestring (used for minimized windows).
  let &iconstring = '(v) '.&titlestring
endfun

augroup vimrc_title
  au!
  " XXX: might not get called with fugitive buffers (title is the (closed) fugitive buffer).
  autocmd BufEnter * call MySetupTitleString()
augroup END

" Make Vim set the window title according to &titlestring.
if !has('gui_running') && empty(&t_ts)
  if len($TMUX)
    let &t_ts = "\e]2;"
    let &t_fs = "\007"
  elseif &term =~ "^screen.*"
    let &t_ts="\ek"
    let &t_fs="\e\\"
  endif
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

" yankstack, see also unite's history/yank {{{1
if &rtp =~ '\<yankstack\>'
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
omap s <Plug>Sneak_s
omap S <Plug>Sneak_S

" Use streak mode, also for Sneak_f/Sneak_t.
let g:sneak#streak=2
let g:sneak#s_next = 1  " clever-s
let g:sneak#target_labels = "sfjktunbqz/SFKGHLTUNBRMQZ?"

" Replace 'f' with inclusive 1-char Sneak.
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

" GoldenView {{{1
let g:goldenview__enable_default_mapping = 0
let g:goldenview__enable_at_startup = 0

" 1. split to tiled windows
nmap <silent> g<C-L>  <Plug>GoldenViewSplit

" " 2. quickly switch current window with the main pane
" " and toggle back
nmap <silent> <F9>   <Plug>GoldenViewSwitchMain
nmap <silent> <S-F9> <Plug>GoldenViewSwitchToggle

" " 3. jump to next and previous window
nmap <silent> <C-N>  <Plug>GoldenViewNext
nmap <silent> <C-P>  <Plug>GoldenViewPrevious
" }}}

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

" Toggle settings, mnemonic "set paste", "set color", ..
" NOTE: see also unimpaired
set pastetoggle=<leader>sp
nnoremap <leader>sc :ColorToggle<cr>
nnoremap <leader>sq :QuickfixsignsToggle<cr>
nnoremap <leader>si :IndentGuidesToggle<cr>
" Toggle mouse.
nnoremap <leader>sm :exec 'set mouse='.(&mouse == 'a' ? '' : 'a')<cr>:set mouse?<cr>

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
" NOTE: relativenumber might slow Vim down: https://code.google.com/p/vim/issues/detail?id=311
set norelativenumber
fun! MySetDefaultNumberSettings()
  if &ft =~# 'qf\|cram\|vader'
    setl number
  elseif &buftype ==# "nofile" ||bufname("%") =~ '^__' || &ft == "help"
    setl nonumber
  elseif winwidth(".") > 90
    set number
  else
    set nonumber
  endif
endfun
" No relative numbers with quickfix and other special windows like __TMRU__.
augroup vimrc_number_setup
  au!
  au VimResized,FileType,BufWinEnter * call MySetDefaultNumberSettings()
  au CmdwinEnter * setl number norelativenumber
augroup END
let &showbreak = '↪ '
set cpoptions+=n  " Use line column for wrapped text / &showbreak.
function! CycleLineNr()
  " states: [start] => norelative/number => relative/number (=> relative/nonumber) => nonumber/norelative
  if exists('+relativenumber')
    if &relativenumber
      " if &number
      "   set relativenumber nonumber
      " else
        set norelativenumber nonumber
      " endif
    else
      if &number
        set number relativenumber
        if !&number  " Older Vim.
          set relativenumber
        endif
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
nnoremap <leader>sa :call CycleLineNr()<CR>

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
nnoremap coa :call ToggleLineNr()<cr>

" Allow cursor to move anywhere in all modes.
nnoremap cov :set <C-R>=empty(&virtualedit) ? 'virtualedit=all' : 'virtualedit='<CR><CR>
"}}}

" Tab completion options
" (only complete to the longest unambiguous match, and show a menu)
" set completeopt=longest,menu
set completeopt=longest,menuone
" set completeopt+=preview  " experimental
set wildmode=list:longest,list:full
" set complete+=kspell " complete from spell checking
" set dictionary+=spell " very useful (via C-X C-K), but requires ':set spell' once

" NOTE: gets handled dynamically via cursorcross plugin.
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

" Improve the Esc key: good for `i`, does not work for `a`.
" Source: http://vim.wikia.com/wiki/Avoid_the_escape_key#Improving_the_Esc_key
" inoremap <Esc> <Esc>`^

" close tags (useful for html)
" NOTE: not required/used; avoid imap for leader.
" imap <Leader>/ </<C-X><C-O>

nnoremap <Leader>a :Ag<space>
nnoremap <Leader>A :Ag!<space>

" Make those behave like ci' , ci"
nnoremap ci( f(ci(
nnoremap ci{ f{ci{
nnoremap ci[ f[ci[
" NOTE: occupies `c`.
" vnoremap ci( f(ci(
" vnoremap ci{ f{ci{
" vnoremap ci[ f[ci[

" 'goto buffer'; NOTE: overwritten with Unite currently.
nnoremap gb :ls<CR>:b

function! MyIfToVarDump()
  normal yyP
  s/\mif\>/var_dump/
  s/\m\s*\(&&\|||\)\s*/, /ge
  s/\m{\s*$/; die();/
endfunction

" Toggle fold under cursor.  {{{
fun! MyToggleFold()
  if !&foldenable
    echom "Folds are not enabled."
  endif
  let level = foldlevel('.')
  echom "Current foldlevel:" level
  if level == 0
    return
  endif
  if foldclosed('.') > 0
    " Open recursively
    norm! zA
  else
    " Close only one level.
    norm! za
  endif
endfun
nnoremap <Leader><space> :call MyToggleFold()<cr>
vnoremap <Leader><space> zf
" }}}

" Easily switch between different fold methods {{{
" Source: https://github.com/pydave/daveconfig/blob/master/multi/vim/.vim/bundle/foldtoggle/plugin/foldtoggle.vim
nnoremap <Leader>sf :call ToggleFold()<CR>
function! ToggleFold()
  if !exists("b:fold_toggle_options")
    " By default, use the main three. I rarely use custom expressions or
    " manual and diff is just for diffing.
    let b:fold_toggle_options = ["syntax", "indent", "marker"]
    if len(&foldexpr)
      let b:fold_toggle_options += ["expr"]
    endif
  endif

  " Find the current setting in the list
  let i = match(b:fold_toggle_options, &foldmethod)

  " Advance to the next setting
  let i = (i + 1) % len(b:fold_toggle_options)
  let old_method = &l:foldmethod
  let &l:foldmethod = b:fold_toggle_options[i]

  echom 'foldmethod: ' . old_method . " => " . &l:foldmethod
endfunction

function! FoldParagraphs()
    setlocal foldmethod=expr
    setlocal fde=getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1
endfunction
command! FoldParagraphs call FoldParagraphs()
" }}}

" Sort Python imports.
command! -range=% Isort :<line1>,<line2>! isort --lines 79 -

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
" select last inserted text
" nnoremap gV `[v`]
nmap gV <leader>gp


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
  let s_report = &report
  let &report=0
  let pattern = a:0 ? a:1 : '[\\]\@<!\s\+$'
  if exists('*winsaveview')
    let oldview = winsaveview()
  else
    let save_cursor = getpos(".")
  endif
  exe 'keepjumps keeppatterns '.a:line1.','.a:line2.'substitute/'.pattern.'//e'
  if exists('oldview')
    if oldview != winsaveview()
      redraw
      echohl WarningMsg | echomsg 'Trimmed whitespace.' | echohl None
    endif
    call winrestview(oldview)
  else
    call setpos('.', save_cursor)
  endif
  let &report = s_report
endfunction
command! -range=% -nargs=0 -bar Untrail keepjumps call StripWhitespace(<line1>,<line2>)
" Untrail, for pastes from tmux (containing border).
command! -range=% -nargs=0 -bar UntrailSpecial keepjumps call StripWhitespace(<line1>,<line2>,'[\\]\@<!\s\+│\?$')
nnoremap <leader>st :Untrail<CR>

" Source/execute current line/selection/operator-pending. {{{
" This uses a temporary file instead of "exec", which does not handle
" statements after "endfunction".
fun! SourceViaFile() range
  echom "first/last" a:firstline a:lastline
  let tmpfile = tempname()
  exe a:firstline.",".a:lastline."w ".tmpfile
  exe "source" tmpfile
  if &verbose
    echom "Sourced ".(a:lastline - a:firstline + 1)." lines."
  endif
endfun
command! -range SourceThis <line1>,<line2>call SourceViaFile()

map <Leader><  <Plug>(operator-source)
nnoremap <Leader><<  :call SourceViaFile()<cr>
if &rtp =~ '\<operator-user\>'
  call operator#user#define('source', 'Op_source_via_file')
  " call operator#user#define_ex_command('source', 'SourceThis')
  function! Op_source_via_file(motion_wiseness)
    " execute (line("']") - line("'[") + 1) 'wincmd' '_'
    '[,']call SourceViaFile()
  endfunction
endif
" }}}


" Shortcut for <C-r>= in cmdline.
fun! RR(...)
  return call(ProjectRootGuess, a:000)
endfun
command! RR ProjectRootLCD
command! RRR ProjectRootCD

" Follow symlink and lcd to root.
nnoremap <Leader>fr :FollowSymlink <bar> ProjectRootLCD<CR>

" Toggle pattern (typically a char) at the end of line(s). {{{2
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
if has('vim_starting')
  noremap <unique> <Leader>,; :call MyToggleLastChar(';')<cr>
  noremap <unique> <Leader>,: :call MyToggleLastChar(':')<cr>
  noremap <unique> <Leader>,, :call MyToggleLastChar(',')<cr>
  noremap <unique> <Leader>,. :call MyToggleLastChar('.')<cr>
  noremap <unique> <Leader>,qa :call MyToggleLastChar('  # noqa')<cr>
endif


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

" Twiddle case of chars / visual selection. {{{2
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
" }}}2

" Exit if the last window is a controlling one (NERDTree, qf). {{{2
function! s:CloseIfOnlyControlWinLeft()
  if winnr("$") != 1
    return
  endif
  " Alt Source: https://github.com/scrooloose/nerdtree/issues/21#issuecomment-3348390
  " autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
  if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
        \ || &buftype == 'quickfix'
    " NOTE: problematic with Unite's directory, when opening a file:
    " :Unite from startify, then quitting Unite quits Vim; also with TMRU from
    " startify.
        " \ || &ft == 'startify'
    q
  endif
endfunction
augroup CloseIfOnlyControlWinLeft
  au!
  au BufEnter * call s:CloseIfOnlyControlWinLeft()
augroup END
" }}}2

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
  " NOTE: nested is required for Neovim to trigger FileChangedShellPost
  "       autocommand with :checktime.
  au FocusGained,BufEnter,CursorHold,InsertEnter * nested call MyAutoCheckTime()
augroup END
command! NoAutoChecktime let b:autochecktime=0
command! ToggleAutoChecktime let b:autochecktime=!get(b:, 'autochecktime', 0) | echom "b:autochecktime:" b:autochecktime

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
let g:easytags_async = 1

let g:detectindent_preferred_indent = 2 " used for sw and ts if only tabs
let g:detectindent_preferred_expandtab = 1
let g:detectindent_min_indent = 2
let g:detectindent_max_indent = 4
let g:detectindent_max_lines_to_analyse = 100

" command-t plugin {{{
let g:CommandTMaxFiles=50000
let g:CommandTMaxHeight=20
" NOTE: find finder does not skip g:CommandTWildIgnore for scanning!
" let g:CommandTFileScanner='find'
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

" Setup completefunc / base completion. {{{
" (used as fallback (manual)).
" au FileType python set completefunc=eclim#python#complete#CodeComplete
if !s:use_ycm && has("autocmd") && exists("+omnifunc")
  augroup vimrc_base_omnifunc
    au!
  if &rtp =~ '\<eclim\>'
    au FileType * if index(
          \ ["php", "javascript", "css", "python", "xml", "java", "html"], &ft) != -1 |
          \ let cf="eclim#".&ft."#complete#CodeComplete" |
          \ exec 'setlocal omnifunc='.cf |
          \ endif
    " function! eclim#php#complete#CodeComplete(findstart, base)
    " function! eclim#javascript#complete#CodeComplete(findstart, base)
    " function! eclim#css#complete#CodeComplete(findstart, base)
    " function! eclim#python#complete#CodeComplete(findstart, base) " {{{
    " function! eclim#xml#complete#CodeComplete(findstart, base)
    " function! eclim#java#complete#CodeComplete(findstart, base) " {{{
    " function! eclim#java#ant#complete#CodeComplete(findstart, base)
    " function! eclim#html#complete#CodeComplete(findstart, base)
  else
    au FileType css setlocal omnifunc=csscomplete#CompleteCSS
    au FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    au FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    au FileType python setlocal omnifunc=pythoncomplete#Complete
    au FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    "au FileType ruby setlocal omnifunc=rubycomplete#Complete
  endif
  au FileType htmldjango set omnifunc=htmldjangocomplete#CompleteDjango

  " Use syntaxcomplete, if there is no better omnifunc.
  autocmd Filetype *
        \ if &omnifunc == "" |
        \   setlocal omnifunc=syntaxcomplete#Complete |
        \ endif
  augroup END
endif
" }}}


" supertab.vim {{{
if &rtp =~ '\<supertab\>'
  " "context" appears to trigger path/file lookup?!
  " let g:SuperTabDefaultCompletionType = 'context'
  " let g:SuperTabContextDefaultCompletionType = "<c-p>"
  " let g:SuperTabContextTextFileTypeExclusions =
  "   \ ['htmldjango', 'htmljinja', 'javascript', 'sql']

  " auto select the first result when using 'longest'
  "let g:SuperTabLongestHighlight = 1 " triggers bug with single match (https://github.com/ervandew/supertab/commit/e026bebf1b7113319fc7831bc72d0fb6e49bd087#commitcomment-297471)

  " let g:SuperTabLongestEnhanced = 1  " involves mappings; requires
  " completeopt =~ longest
  let g:SuperTabClosePreviewOnPopupClose = 1
  let g:SuperTabNoCompleteAfter = ['^', '\s']

  " map <c-space> to <c-p> completion (useful when supertab 'context'
  " defaults to something else).
  " imap <nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-p>")<cr>

  " Setup completion with SuperTab: default to omnifunc (YouCompleteMe),
  " then completefunc.
  if s:use_ycm
    " Call YouCompleteMe always (semantic).
    " Let &completefunc untouched (eclim).
    " Use autocommand to override any other automatic setting from filetypes.
    " Use SuperTab chaining to fallback to "<C-p>".
    " autocmd FileType *
    "       \ let g:ycm_set_omnifunc = 0 |
    "       \ set omnifunc=youcompleteme#OmniComplete
    " let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
    fun! CompleteViaSuperTab(findstart, base)
      let old = g:ycm_min_num_of_chars_for_completion
      " 0 would trigger/force semantic completion (results in everything after
      " a dot also).
      let g:ycm_min_num_of_chars_for_completion = 1
      let r = youcompleteme#Complete(a:findstart, a:base)
      let g:ycm_min_num_of_chars_for_completion = old
      return r
    endfun
    " completefunc is used by SuperTab's chaining.
    " let ycm_set_completefunc = 0
    autocmd FileType *
          \ call SuperTabChain("CompleteViaSuperTab", "<c-p>") |
          \ call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
    " Let SuperTab trigger YCM always.

    " call SuperTabChain('youcompleteme#OmniComplete', "<c-p>") |
    " let g:SuperTabChain = ['youcompleteme#Complete', "<c-p>"]
    " set completefunc=SuperTabCodeComplete
    " let g:SuperTabDefaultCompletionType = "<c-x><c-u>"
    " autocmd FileType *
    "   \ call SuperTabChain('youcompleteme#Complete', "<c-p>") |
    "   \ call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
  else
    let g:SuperTabDefaultCompletionType = "<c-p>"
    autocmd FileType *
      \ if &omnifunc != '' |
      \   call SuperTabChain(&omnifunc, "<c-p>") |
      \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
      \ elseif &completefunc != '' |
      \   call SuperTabChain(&completefunc, "<c-p>") |
      \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
      \ endif
  endif
endif
" }}}

let g:LustyExplorerSuppressRubyWarning = 1 " suppress warning when vim-ruby is not installed

" use for encryption:
" openssl enc -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd > 1
" openssl enc -d -aes-256-cbc -a -salt -pass file:/home/daniel/.dotfiles/.passwd < 1
let g:pastebin_api_dev_key = '95d8fa0dd25e7f8b924dd8103af42218'

let g:EclimLargeFileEnabled = 0
let g:EclimCompletionMethod = 'completefunc' " Default, picked up via SuperTab.
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

" Disable HTML indenting via eclim, ref: https://github.com/ervandew/eclim/issues/332.
let g:EclimHtmlIndentDisabled = 1
let g:EclimHtmldjangoIndentDisabled = 1


" lua {{{
let g:lua_check_syntax = 0  " done via syntastic
let g:lua_define_omnifunc = 0  " must be enabled also (g:lua_complete_omni=1, but crashes Vim!)
let g:lua_complete_keywords = 0 " interferes with YouCompleteMe
let g:lua_complete_globals = 0  " interferes with YouCompleteMe?
let g:lua_complete_library = 0  " interferes with YouCompleteMe
let g:lua_complete_dynamic = 0  " interferes with YouCompleteMe
let g:lua_complete_omni = 0     " Disabled by default. Likely to crash Vim!
let g:lua_define_completion_mappings = 0
" }}}

" Prepend <leader> to visualctrlg mappings.
let g:visualctrg_no_default_keymappings = 1
silent! vmap <unique> <Leader><C-g>  <Plug>(visualctrlg-briefly)
silent! vmap <unique> <Leader>g<C-g> <Plug>(visualctrlg-verbosely)

" Toggle quickfix window, using <Leader>qq. {{{2
" Based on: http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
nnoremap <Leader>qq :QFix<CR>
nnoremap <Leader>cc :QFix<CR>
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("t:qfix_buf") && bufwinnr(t:qfix_buf) != -1 && a:forced == 0
    cclose
  else
    copen
    let t:qfix_buf = bufnr("%")
  endif
endfunction
" Used to track manual opening of the quickfix, e.g. via `:copen`.
augroup QFixToggle
  au!
  au BufWinEnter quickfix let g:qfix_buf = bufnr("%")
augroup END
" 2}}}

" Adjust height of quickfix window {{{2
" Based on http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
augroup AdjustWindowHeight
  au!
  au FileType qf call AdjustWindowHeight(1, 10)
augroup END
function! AdjustWindowHeight(minheight, maxheight)
  if exists('w:did_AdjustWindowHeight')
    return
  endif

  let newheight = max([min([line("$"), a:maxheight]), a:minheight])
  let diff = newheight - winheight(0)
  if diff == 0 | return | endif

  let w:did_AdjustWindowHeight = 1

  " Special handling for if there are windows below.
  " (For example from "belowright copen")
  " The size adjustment should be carried out to the windows above.
  let orig_winnr = winnr()
  let orig_prev_winnr = winnr('#')

  let windows_below = []
  let w = orig_winnr
  while 1
    noautocmd wincmd j
    if w == winnr()
      break
    endif
    let w = winnr()
    if ! &winfixheight
      let windows_below += [w]
    endif
  endwhile

  " Go back to current window, restoring "wincmd p" functionality.
  exe 'noautocmd' orig_prev_winnr 'wincmd w'
  exe 'noautocmd' orig_winnr 'wincmd w'

  " Lock height of windows below.
  for w in windows_below
    call setwinvar(w, '&winfixheight', 1)
  endfor

  exe newheight "wincmd _"

  " Unlock height of windows below.
  for w in windows_below
    call setwinvar(w, '&winfixheight', 0)
  endfor
endfunction
" 2}}}
endif " 1}}} eval guard

" Mappings {{{1
" Save.
nnoremap <C-s>     :up<CR>
inoremap <C-s>     <Esc>:up<CR>

" swap n_CTRL-Z and n_CTRL-Y (qwertz layout; CTRL-Z should be next to CTRL-U)
nnoremap <C-z> <C-y>
nnoremap <C-y> <C-z>
" map! <C-Z> <C-O>:stop<C-M>

" zi: insert one char
" map zi i$<ESC>r

" defined in php-doc.vim
" nnoremap <Leader>d :call PhpDocSingle()<CR>

noremap <Leader>n :NERDTree<space>
noremap <Leader>n. :execute "NERDTree ".expand("%:p:h")<cr>
noremap <Leader>nb :NERDTreeFromBookmark<space>
noremap <Leader>nn :NERDTreeToggle<cr>
noremap <Leader>no :NERDTreeToggle<space>
noremap <Leader>nf :NERDTreeFind<cr>
noremap <Leader>nc :NERDTreeClose<cr>
noremap <S-F1> :tab<Space>:help<Space>
" ':tag {ident}' - difficult on german keyboard layout and not working in gvim/win32
noremap <F2> g<C-]>
" expand abbr (insert mode and command line)
noremap! <F2> <C-]>
noremap <F3> :if exists('g:tmru#world')<cr>:let g:tmru#world.restore_from_cache = []<cr>:endif<cr>:TRecentlyUsedFiles<cr>
noremap <S-F3> :if exists('g:tmru#world')<cr>:let g:tmru#world.restore_from_cache = ['filter']<cr>:endif<cr>:TRecentlyUsedFiles<cr>
" XXX: mapping does not work (autoclose?!)
" noremap <F3> :CtrlPMRUFiles
fun! MyF5()
  if &diff
    diffupdate
  else
    e
  endif
endfun
noremap <F5> :call MyF5()<cr>
" noremap <F11> :YRShow<cr>
" if has('gui_running')
"   map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>
"   imap <silent> <F11> <Esc><F11>a
" endif

" }}}

" tagbar plugin
nnoremap <silent> <F8> :TagbarToggle<CR>
nnoremap <silent> <Leader><F8> :TagbarOpenAutoClose<CR>

" VimFiler {{{2
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_ignore_filters = ['matcher_ignore_wildignore']

" Netrw {{{2
" Short-circuit detection, which might be even wrong.
let g:netrw_browsex_viewer = 'open-in-running-browser'

" NERDTree {{{2
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

" TODO
" noremap <Up> gk
" noremap <Down> gj
" (Cursor keys should be consistent between insert and normal mode)
" slow!
" inoremap <Up> <C-O>:normal gk<CR>
" inoremap <Down> <C-O>:normal gj<CR>
"
" j,k move by screen line instead of file line.
" nnoremap j gj
" nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
" inoremap <Down> <C-o>gj
" inoremap <Up> <C-o>gk
" XXX: does not keep virtual column! Also adds undo points!
" inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"
" inoremap <expr> <Up>   pumvisible() ? "\<C-p>" : "\<C-o>gk"

" Make C-BS and C-Del work like they do in most text editors for the sake of muscle memory {{{2
imap <C-BS> <C-W>
imap <C-Del> <C-O>dw
imap <C-S-Del> <C-O>dW

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
  let cmd = a:0 ? a:1 : (WindowIsEmpty() ? 'e' : 'vsplit')
  exec cmd a:path
endfunction

" edit vimrc shortcut
nnoremap <leader>ec :call MyEditConfig(resolve($MYVIMRC))<cr>
nnoremap <leader>Ec :call MyEditConfig(resolve($MYVIMRC), 'edit')<cr>
" edit zshrc shortcut
nnoremap <leader>ez :call MyEditConfig(resolve("~/.zshrc"))<cr>
" edit .lvimrc shortcut (in repository root)
nnoremap <leader>elv :call MyEditConfig(ProjectRootGuess().'/.lvimrc')<cr>
nnoremap <leader>em :call MyEditConfig(ProjectRootGuess().'/Makefile')<cr>

nnoremap <leader>et :call MyEditConfig(expand('~/TODO'))<cr>
nnoremap <leader>ept :call MyEditConfig(ProjectRootGet().'/TODO')<cr>

" Utility functions to create file commands
" Source: https://github.com/carlhuda/janus/blob/master/gvimrc
" function! s:CommandCabbr(abbreviation, expansion)
"   execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
" endfunction

" Open URL
nmap <leader>gw <Plug>(openbrowser-smart-search)
vmap <leader>gw <Plug>(openbrowser-smart-search)

" Remap CTRL-W_ using vim-maximizer (smarter and toggles).
nnoremap <silent><c-w>_ :MaximizerToggle<CR>
vnoremap <silent><F3> :MaximizerToggle<CR>gv
inoremap <silent><F3> <C-o>:MaximizerToggle<CR>


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
" nnoremap <Leader>gD :Git difftool %
nnoremap <Leader>gb :Gblame<cr>
nnoremap <Leader>gl :Glog<cr>
nnoremap <Leader>gs :Gstatus<cr>

" Shortcuts for committing.
nnoremap <Leader>gc :Gcommit -v
command! -nargs=1 Gcm Gcommit -m <q-args>
" }}}1

" "wincmd p" might not work initially, although there are two windows.
fun! MyWincmdPrevious()
  let w = winnr()
  wincmd p
  if winnr() == w
    wincmd w
  endif
endfun
" Diff this window with the previous one.
command! DiffThese diffthis | call MyWincmdPrevious() | diffthis | wincmd p
command! DiffOff   Windo diffoff


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
  "       Needs patch: https://github.com/Valloric/YouCompleteMe/pull/830
  set nomodified ft=vim.ycmblacklisted
  norm! gg
endfunction
command! -nargs=* -complete=command Redir call RedirCommand(<q-args>, 'tabnew')
" cnoreabbrev TM TabMessage
command! -nargs=* -complete=command Redirbuf call RedirCommand(<q-args>, 'new')
command! Maps Redir map

" fun! Cabbrev(key, value)
"   exe printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
"     \ a:key, 1+len(a:key), string(a:value), string(a:key))
" endfun
" " IDEA: requires expansion of abbr.
" call Cabbrev('/',   '/\v')
" call Cabbrev('?',   '?\v')
" call Cabbrev('s/',  's/\v')
" call Cabbrev('%s/', '%s/\v')

" Make Y consistent with C and D / copy selection to gui-clipboard. {{{2
nnoremap Y y$
" copy selection to gui-clipboard
xnoremap Y "+y

" Cycle history.
cnoremap <c-j> <up>
cnoremap <c-k> <down>

" Move without arrow keys. {{{2
inoremap <m-h> <left>
inoremap <m-l> <right>
inoremap <m-j> <down>
inoremap <m-k> <up>
cnoremap <m-h> <left>
cnoremap <m-l> <right>

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
  function! Windo(command)
    let curaltwin = winnr('#') ? winnr('#') : 1
    let currwin = winnr()
    execute 'windo ' . a:command
    execute curaltwin . 'wincmd w'
    execute currwin . 'wincmd w'
  endfunction
  com! -nargs=+ -complete=command Windo call Windo(<q-args>)

  " Like bufdo but restore the current buffer.
  function! Bufdo(command)
    let currBuff = bufnr("%")
    execute 'bufdo ' . a:command
    execute 'buffer ' . currBuff
  endfunction
  com! -nargs=+ -complete=command Bufdo call Bufdo(<q-args>)

  " Like tabdo but restore the current tab.
  function! Tabdo(command)
    let currTab=tabpagenr()
    execute 'tabdo ' . a:command
    execute 'tabn ' . currTab
  endfunction
  com! -nargs=+ -complete=command Tabdo call Tabdo(<q-args>)
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
inoreabbr cdata <![CDATA[]]><Left><Left><Left>
inoreabbr sg  Sehr geehrte Damen und Herren,<cr>
inoreabbr sgh Sehr geehrter Herr<space>
inoreabbr sgf Sehr geehrte Frau<space>
inoreabbr mfg Mit freundlichen Grüßen,<cr><C-g>u<C-r>=g:my_full_name<cr>
inoreabbr LG Liebe Grüße,<cr>Daniel.
inoreabbr VG Viele Grüße,<cr>Daniel.
" iabbr sig -- <cr><C-r>=readfile(expand('~/.mail-signature'))
" ellipsis
inoreabbr ... …
" sign "checkmark"
inoreabbr scm ✓
" date timestamp.
inoreabbr <expr> dts strftime('%a, %d %b %Y %H:%M:%S %z')
inoreabbr <expr> ds strftime('%a, %d %b %Y')
" date timestamp with fold markers.
inoreabbr dtsf <C-r>=strftime('%a, %d %b %Y %H:%M:%S %z')<cr><space>{{{<cr><cr>}}}<up>
" German/styled quotes.
inoreabbr <silent> _" „“<Left>
inoreabbr <silent> _' ‚‘<Left>
inoreabbr <silent> _- –<space>
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
let g:CommandTWildIgnore=&wildignore
      \ .',htdocs/asset/**'
      \ .',htdocs/media/**'
      \ .',**/static/_build/**'
      \ .',**/node_modules/**'
      \ .',**/cache/**'
      \ .',**/build/**'
      " \ .',**/bower_components/*'

let g:vdebug_keymap = {
\    "run" : "<S-F5>",
\}
command! VdebugStart python debugger.run()

" LocalVimRC {{{
let g:localvimrc_sandbox = 0 " allow to adjust/set &path
let g:localvimrc_persistent = 1 " 0=no, 1=uppercase, 2=always
" let g:localvimrc_debug = 1
let g:localvimrc_persistence_file = g:vimsharedir . '/localvimrc_persistent'

" Helper method for .lvimrc files to finish
fun! MyLocalVimrcAlreadySourced(...)
  " let sfile = expand(a:sfile)
  let sfile = g:localvimrc_script
  let guard_key = expand(sfile).'_'.getftime(sfile)
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
let g:session_default_name = ''
let g:session_command_aliases = 1
let g:session_persist_globals = [
      \ 'g:tmru_file',
      \ 'g:session_autosave',
      \ 'g:MySessionName']
" call add(g:session_persist_globals, 'g:session_autoload')
let g:session_persist_colors = 0

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
let g:html_indent_autotags = "br,input,img"


" better-whitespace: disable by default.
" TODO: DisableWhitespace is buggy across buffers?!
if &rtp =~ '\<better-whitespace\>'
  let g:better_whitespace_enabled = 0
  nmap <Leader>sw :ToggleWhitespace<cr>
  augroup MyBetterWhitespace
    au!
    au FileType * if &buftype == 'nofile' | exec 'DisableWhitespace' | endif
    au FileType diff,gitcommit DisableWhitespace
  augroup END
endif


" Setup late autocommands {{{
if has('autocmd')
  augroup vimrc_late
    au!
    " See also ~/.dotfiles/usr/bin/vim-for-git, which uses this setup and
    " additionally splits the window.
    fun! MySetupGitCommitMsg()
      if bufname("%") == '.git/index'
        " fugitive :Gstatus
        return
      endif
      set foldmethod=syntax foldlevel=1
      set nohlsearch nospell sw=4 scrolloff=0
      silent g/^# \(Changes not staged\|Untracked files\)/norm zc
      normal! zt
      set spell spl=en,de
    endfun
    au FileType gitcommit call MySetupGitCommitMsg()


    " Detect indent.
    au FileType mail,make,python let b:no_detect_indent=1
    au BufReadPost * if exists(':DetectIndent') |
          \ if !exists('b:no_detect_indent') || !b:no_detect_indent |
          \   exec 'DetectIndent' |
          \ endif | endif

    au BufReadPost * if &bt == "quickfix" | set nowrap | endif

    " Check if the new file (with git-diff prefix removed) is readable and
    " edit that instead (copy'n'paste from shell).
    " (for git diff: `[abiw]`).
    au BufNewFile * nested let s:fn = expand('<afile>') | if ! filereadable(s:fn) | let s:fn = substitute(s:fn, '^\S\{-}/', '', '') | if filereadable(s:fn) | echomsg 'Editing' s:fn 'instead' | exec 'e '.s:fn.' | bd#' | endif | endif

    " Display a warning when editing foo.css, but foo.{scss,sass} exists.
    au BufRead *.css if &modifiable
          \ && (glob(expand('<afile>:r').'.s[ca]ss', 1) != ""
          \ || glob(substitute(expand('<afile>'), 'css', 's[ac]ss', 'g')) != "")
          \ |   echoerr "WARN: editing .css, but .scss/.sass exists!"
          \ |   set nomodifiable readonly
          \ | endif

    " Vim help files: modidiable (easier to edit for typo fixes); buflisted
    " for easier switching to them.
    au FileType help setl modifiable buflisted
  augroup END
endif " }}}


" delimitMate
let delimitMate_excluded_ft = "unite"
" let g:delimitMate_balance_matchpairs = 1
" let g:delimitMate_expand_cr = 1
" let g:delimitMate_expand_space = 1
" au FileType c,perl,php let b:delimitMate_eol_marker = ";"
" (pre-)Override S-Tab mapping
" Orig: silent! imap <unique> <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "<Plug>delimitMateS-Tab"
" Ref: https://github.com/Raimondi/delimitMate/pull/148#issuecomment-29428335
" NOTE: mapped by SuperTab now.
" imap <buffer> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "<Plug>delimitMateS-Tab"


if has('vim_starting') " only do this on startup, not when reloading .vimrc
  " Don't move when you use *
  " nnoremap <silent> * :let stay_star_view = winsaveview()<cr>*:call winrestview(stay_star_view)<cr>
endif

" Map alt sequences for terminal via Esc.
" source: http://stackoverflow.com/a/10216459/15690
" NOTE: <Esc>O is used for special keys (e.g. OF (End))
" NOTE: drawback (with imap) - triggers timeout for Esc: use jk/kj,
"       or press it twice.
" NOTE: Alt-<NR> mapped in tmux. TODO: change this?!
if ! has('nvim') && ! has('gui_running')
  fun! MySetupAltMapping(c)
    " XXX: causes problems in macros: <Esc>a gets mapped to á.
    "      Solution: use <C-c> / jk in macros.
    exec "set <A-".a:c.">=\e".a:c
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
  " for c in [',', '.', '-', 'ö', 'ä', '#', 'ü', '+', '<']
  for c in [',', '.', '-', '#', '+', '<']
    call MySetupAltMapping(c)
  endfor
endif

" Fix (shifted, altered) function and special keys in tmux. {{{
" (requires `xterm-keys` option for tmux, works with screen).
" Ref: http://unix.stackexchange.com/a/58469, http://superuser.com/a/402084/30216
" See also: https://github.com/nacitar/terminalkeys.vim/blob/master/plugin/terminalkeys.vim

" With tmux' 'xterm-keys' option, we can make use of these. {{{
" Based on tmux's examples/xterm-keys.vim.
" NOTE: using this always, with adjusted urxvt keysym.
execute "set <xUp>=\e[1;*A"
execute "set <xDown>=\e[1;*B"
execute "set <xRight>=\e[1;*C"
execute "set <xLeft>=\e[1;*D"

" NOTE: xHome/xEnd used with real xterm
" execute "set <xHome>=\e[1;*H"
" execute "set <xEnd>=\e[1;*F"

" also required for xterm hack with urxvt.
execute "set <Insert>=\e[2;*~"
execute "set <Delete>=\e[3;*~"
execute "set <PageUp>=\e[5;*~"
execute "set <PageDown>=\e[6;*~"

" NOTE: breaks real xterm
" execute "set <xF1>=\e[1;*P"
" execute "set <xF2>=\e[1;*Q"
" execute "set <xF3>=\e[1;*R"
" execute "set <xF4>=\e[1;*S"

execute "set <F5>=\e[15;*~"
execute "set <F6>=\e[17;*~"
execute "set <F7>=\e[18;*~"
execute "set <F8>=\e[19;*~"
execute "set <F9>=\e[20;*~"
execute "set <F10>=\e[21;*~"
execute "set <F11>=\e[23;*~"
execute "set <F12>=\e[24;*~"
" }}}


" Change cursor shape for terminal mode. {{{1
" See also ~/.dotfiles/oh-my-zsh/themes/blueyed.zsh-theme.
" Note: with neovim, this gets controlled via $NVIM_TUI_ENABLE_CURSOR_SHAPE.
if !has('nvim') && exists('&t_SI')
  " 'start insert' and 'exit insert'.
  if $_USE_XTERM_CURSOR_CODES == 1
    " Reference: {{{
    " P s = 0 → blinking block.
    " P s = 1 → blinking block (default).
    " P s = 2 → steady block.
    " P s = 3 → blinking underline.
    " P s = 4 → steady underline.
    " P s = 5 → blinking bar (xterm, urxvt).
    " P s = 6 → steady bar (xterm, urxvt).
    " Source: http://vim.wikia.com/wiki/Configuring_the_cursor
    " }}}
    let &t_SI = "\<Esc>[5 q"
    let &t_EI = "\<Esc>[1 q"

    " let &t_SI = "\<Esc>]12;purple\x7"
    " let &t_EI = "\<Esc>]12;blue\x7"

    " mac / iTerm?!
    " let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    " let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  elseif $KONSOLE_PROFILE_NAME =~ "^Solarized.*"
    let &t_EI = "\<Esc>]50;CursorShape=0;BlinkingCursorEnabled=1\x7"
    let &t_SI = "\<Esc>]50;CursorShape=1;BlinkingCursorEnabled=1\x7"
  elseif &t_Co > 1 && $TERM != "linux"
    " Fallback (e.g. for gnome-terminal): change only the color of the cursor.
    let &t_SI = "\<Esc>]12;#0087ff\x7"
    let &t_EI = "\<Esc>]12;#5f8700\x7"
  endif
endif
" Wrap escape codes for tmux.
" NOTE: wrapping it acts on the term, not just on the pane!
" if len($TMUX)
"   let &t_SI = "\<Esc>Ptmux;\<Esc>".&t_SI."\<Esc>\\"
"   let &t_EI = "\<Esc>Ptmux;\<Esc>".&t_EI."\<Esc>\\"
" endif
" }}}

" Delete all but the current buffer. {{{
" Source: http://vim.1045645.n5.nabble.com/Close-all-buffers-except-the-one-you-re-in-tp1183357p1183361.html
com! -bar -bang BDOnly call s:BdOnly(<q-bang>)

func! s:BdOnly(bang)
    let bdcmd = "bdelete". a:bang
    let bnr = bufnr("")
    if bnr > 1
        call s:ExecCheckBdErrs("1,".(bnr-1). bdcmd)
    endif
    if bnr < bufnr("$")
        call s:ExecCheckBdErrs((bnr+1).",".bufnr("$"). bdcmd)
    endif
endfunc

func! s:ExecCheckBdErrs(bdrangecmd)
    try
        exec a:bdrangecmd
    catch /:E51[567]:/
        " no buffers unloaded/deleted/wiped out: ignore
    catch
        echohl ErrorMsg
        echomsg matchstr(v:exception, ':\zsE.*')
        echohl none
    endtry
endfunc
" }}}


" Automatic swapfile handling.
augroup VimrcSwapfileHandling
  au!
  au SwapExists * call MyHandleSwapfile(expand('<afile>:p'))
augroup END
fun! MyHandleSwapfile(filename)
  " If swapfile is older than file itself, just get rid of it.
  if getftime(v:swapname) < getftime(a:filename)
    call MyWarningMsg('Old swapfile detected, and deleted.')
    call delete(v:swapname)
    let v:swapchoice = 'e'
  else
    call MyWarningMsg('Swapfile detected, opening read-only.')
    let v:swapchoice = 'o'
  endif
endfun


" Python setup for NeoVim. {{{
" Defining it also skips auto-detecting it.
if has("nvim")
  " Arch Linux, with python-neovim packages.
  if len(glob('/usr/lib/python2*/site-packages/neovim/__init__.py', 1))
    let g:python_host_prog="/usr/bin/python2"
  endif
  if len(glob('/usr/lib/python3*/site-packages/neovim/__init__.py', 1))
    let g:python3_host_prog="/usr/bin/python3"
  endif

  fun! s:get_python_from_pyenv(ver)
    if !len($PYENV_ROOT)
      return
    endif

    " XXX: Rather slow.
    " let ret=system('pyenv which python'.a:ver)
    " if !v:shell_error && len(ret)
    "   return ret
    " endif

    " XXX: should be natural sort and/or look for */lib/python3.5/site-packages/neovim/__init__.py.
    let files = sort(glob($PYENV_ROOT."/versions/".a:ver.".*/bin/python", 1, 1), "n")
    if len(files)
      return files[-1]
    endif
    echohl WarningMsg | echomsg "Could not find Python" a:ver "through pyenv!" | echohl None
  endfun

  if !exists('g:python3_host_prog')
    " let g:python3_host_prog = "python3"
    let g:python3_host_prog=s:get_python_from_pyenv(3)
    if !len('g:python3_host_prog')
      echohl WarningMsg | echomsg "Could not find python3 for g:python3_host_prog!" | echohl None
    endif
  endif

  if !exists('g:python_host_prog')
    " Use the Python 2 version YCM was built with.
    if len($PYTHON_YCM) && filereadable($PYTHON_YCM)
      let g:python_host_prog=$PYTHON_YCM

    " Look for installed Python 2 with pyenv.
    else
      let g:python_host_prog=s:get_python_from_pyenv(2)
    endif

    if !len('g:python_host_prog')
      echohl WarningMsg | echomsg "Could not find python2 for g:python_host_prog!" | echohl None
    endif
  endif

  " Avoid loading python3 host: YCM uses Python2 anyway, so prefer it for
  " UltiSnips, too.
  if s:use_ycm && has('nvim') && len(get(g:, 'python_host_prog', ''))
    let g:UltiSnipsUsePythonVersion = 2
  endif
endif  " }}}

" Local config (if any). {{{1
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif


" Local file settings. {{{1
" vim: fdm=marker foldlevel=0
