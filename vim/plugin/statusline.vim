" My custom statusline.
scriptencoding utf-8

if !has('statusline')
  finish
endif

if &runtimepath =~# '\<airline\>'
  finish
endif

if !exists('*ShortenFilename')
  " when using a minimal vimrc etc.
  finish
endif

set showtabline=2

" Helper functions {{{
function! FileSize()
  let bytes = getfsize(expand('%:p'))
  if bytes <= 0
    return ''
  endif
  if bytes < 1024
    return bytes
  else
    return (bytes / 1024) . 'K'
  endif
endfunction

" Get property from highlighting group.
" Based on / copied from  neomake#utils#GetHighlight
" (~/.dotfiles/vim/neobundles/neomake/autoload/neomake/utils.vim).
function! StatuslineGetHighlight(group, what) abort
  let reverse = synIDattr(synIDtrans(hlID(a:group)), 'reverse')
  let what = a:what
  if reverse
    let what = s:ReverseSynIDattr(what)
  endif
  if what[-1:] ==# '#'
      let val = synIDattr(synIDtrans(hlID(a:group)), what, 'gui')
  else
      let val = synIDattr(synIDtrans(hlID(a:group)), what, 'cterm')
  endif
  if empty(val) || val == -1
    let val = 'NONE'
  endif
  return val
endfunction

function! s:ReverseSynIDattr(attr) abort
  if a:attr ==# 'fg'
    return 'bg'
  elseif a:attr ==# 'bg'
    return 'fg'
  elseif a:attr ==# 'fg#'
    return 'bg#'
  elseif a:attr ==# 'bg#'
    return 'fg#'
  endif
  return a:attr
endfunction

function! StatuslineHighlights(...)
  " NOTE: not much gui / termguicolors support!
  " XXX: pretty much specific for solarized_base16.
  " let event = a:0 ? a:1 : ''
  " echom "Calling StatuslineHighlights" a:event
  if &background ==# 'light'
    hi StatColorHi1 ctermfg=21 ctermbg=7
    hi StatColorHi1To2Normal ctermfg=7 ctermbg=8
    hi link StatColorHi1To2 StatColorHi1To2Normal
    exe 'hi StatColorHi1ToBg ctermfg=7 ctermbg='.StatuslineGetHighlight('StatusLine', 'bg')
    hi StatColorHi2 ctermfg=21 ctermbg=8
    exe 'hi StatColorHi2ToBg ctermfg=8 ctermbg='.StatuslineGetHighlight('StatusLine', 'bg')

    exe 'hi StatColorNeomakeGood'
          \ 'ctermfg=white'
          \ 'ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')
    if get(g:, 'solarized_base16', 0)
      hi VertSplit ctermbg=21 cterm=underline
    endif

  else  " dark bg
    " NOTE: using ctermfg=18 for bold support (for fg=0 color 8 is used for bold).
    hi StatColorHi1 ctermfg=18 ctermbg=20
    hi StatColorHi1To2Normal ctermfg=20 ctermbg=19
    hi link StatColorHi1To2 StatColorHi1To2Normal
    exe 'hi StatColorHi1ToBg ctermfg=7 ctermbg='.StatuslineGetHighlight('StatusLine', 'bg')
    " NOTE: using ctermfg=18 for bold support (for fg=0 color 8 is used for bold).
    hi StatColorHi2 ctermfg=18 ctermbg=19
    exe 'hi StatColorHi2ToBg ctermfg=19 ctermbg='.StatuslineGetHighlight('StatusLine', 'bg')

    exe 'hi StatColorNeomakeGood'
          \ 'ctermfg=green'
          \ 'ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')
    if get(g:, 'solarized_base16', 0)
      hi VertSplit ctermbg=18
    endif
  endif
  " exe 'hi StatColorCurHunk cterm=bold'
  "       \ ' ctermfg='.StatuslineGetHighlight('StatColorHi2', 'fg')
  "       \ ' ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')
  exe 'hi StatColorHi2Bold cterm=bold'
        \ ' ctermfg='.StatuslineGetHighlight('StatColorHi2', 'fg')
        \ ' ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')

  hi link StatColorMode StatColorHi1

  " Force/set StatusLineNC based on VertSplit.
  hi clear StatusLineNC
  exe 'hi StatusLineNC'
        \ . ' cterm=underline gui=underline'
        \ . ' ctermfg=' . (&background ==# 'dark' ? 7 : 8)
        \ . ' ctermbg=' . StatuslineGetHighlight('VertSplit', 'bg')
        \ . ' guifg=' . StatuslineGetHighlight('CursorLine', 'bg#')
        \ . ' guibg=' . StatuslineGetHighlight('VertSplit', 'bg#')
  " exe 'hi StatusLineNC ctermfg=7 ctermbg=0 cterm=NONE'
  " (&background ==# 'dark' ? 19 : 20)

  " exe 'hi StatusLineQuickfixNC'
  "       \ . ' cterm=underline'
  "       \ . ' ctermfg=' . (&background ==# 'dark' ? 7 : 21)
  "       \ . ' ctermbg=' . (&background ==# 'dark' ? 7 : 7)

  " hi link StatColorError Error
  " exe 'hi StatColorErrorToBg'
  "       \ . ' ctermfg='.StatuslineGetHighlight('StatColorError', 'bg')
  "       \ . ' ctermbg='.StatuslineGetHighlight('StatusLine', 'bg')
  " exe 'hi StatColorErrorToBgNC'
  "       \ . ' ctermfg='.StatuslineGetHighlight('StatColorError', 'bg')
  "       \ . ' ctermbg='.StatuslineGetHighlight('StatusLineNC', 'bg')
  " exe 'hi StatColorHi1ToError'
  "       \ . ' ctermfg='.StatuslineGetHighlight('StatColorError', 'bg')
  "       \ . ' ctermbg='.StatuslineGetHighlight('StatColorHi1', 'bg')

  " let error_color = StatuslineGetHighlight('Error', 'bg')
  " if error_color == 'NONE'
  "   let error_color = StatuslineGetHighlight('Error', 'fg')
  " endif
  exe 'hi StatColorNeomakeError cterm=NONE'
        \ 'ctermfg=white'
        \ 'ctermbg=red'

  exe 'hi StatColorNeomakeNonError cterm=NONE'
        \ 'ctermfg=white'
        \ 'ctermbg=yellow'

  hi StatColorModified guibg=orange guifg=black ctermbg=yellow ctermfg=white
  hi clear StatColorModifiedNC
  exe 'hi StatColorModifiedNC'
        \ . ' cterm=italic,underline'
        \ . ' ctermfg=' . StatuslineGetHighlight('StatusLineNC', 'fg')
        \ . ' ctermbg='.StatuslineGetHighlight('StatusLineNC', 'bg')
  exe 'hi StatColorHi1To2Modified'
        \ . ' ctermfg='.StatuslineGetHighlight('StatColorModified', 'bg')
        \ . ' ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')
  exe 'hi StatColorHi1To2Insert'
        \ . ' ctermfg=green'
        \ . ' ctermbg='.StatuslineGetHighlight('StatColorHi2', 'bg')

  " tabline
  " exe 'hi TabLineSelSign cterm=underline'
  "       \ . ' ctermfg='.StatuslineGetHighlight('TabLineSel', 'bg')
  "       \ . ' ctermbg='.StatuslineGetHighlight('TabLine', 'bg')
  exe 'hi TabLineCwd cterm=underline'
        \ . ' ctermfg=green'
        \ . ' ctermbg='.StatuslineGetHighlight('TabLine', 'bg')
  exe 'hi TabLineNumber cterm=bold,underline'
        \ . ' ctermfg='.StatuslineGetHighlight('TabLine', 'fg')
        \ . ' ctermbg='.StatuslineGetHighlight('TabLine', 'bg')
  hi! link TabLineSel StatColorHi1
  exe 'hi TabLineNumberSel cterm=bold'
        \ . ' ctermfg='.StatuslineGetHighlight('TabLineSel', 'fg')
        \ . ' ctermbg='.StatuslineGetHighlight('TabLineSel', 'bg')
  " hi! link TabLineNumberSel StatColorMode
endfunction

function! StatuslineModeColor(mode)
  " echom "StatuslineModeColor" a:mode winnr()

  if a:mode ==# 'i'
    " hi StatColor guibg=orange guifg=black ctermbg=white ctermfg=black
    " hi StatColor ctermbg=20 ctermfg=black
    " hi StatColorMode cterm=reverse ctermfg=green
    exe 'hi StatColorMode'
        \ . ' ctermfg='.StatuslineGetHighlight('StatColorHi1', 'fg')
        \ . ' ctermbg=green'

    if &modified
      hi link StatColorHi1To2 StatColorHi1To2Modified
    else
      hi link StatColorHi1To2 StatColorHi1To2Insert
    endif
  elseif a:mode ==# 'r'  " via R
    " hi StatColor guibg=#e454ba guifg=black ctermbg=magenta ctermfg=black
  elseif a:mode ==# 'v'
    " hi StatColor guibg=#e454ba guifg=black ctermbg=magenta ctermfg=black
  else
    " Reset
    hi clear StatColorMode

    if &modified
      hi link StatColorMode StatColorModified
      hi link StatColorHi1To2 StatColorHi1To2Modified
    else
      hi link StatColorMode StatColorHi1
      " hi StatColorHi1To2 ctermfg=19 ctermbg=20
      hi link StatColorHi1To2 StatColorHi1To2Normal
    endif
  endif
endfunction

let s:enabled = 1
function! s:RefreshStatus()
  let winnr = winnr()
  for nr in range(1, winnr('$'))
    if s:enabled
      let stl = getwinvar(nr, '&ft') ==# 'codi' ? '[codi]' : '%!MyStatusLine(' . nr . ', '.(winnr == nr).')'
    else
      let stl = ''
    endif
    call setwinvar(nr, '&statusline', stl)
  endfor
endfunction

" Clear cache of corresponding real buffer when saving a fugitive buffer.
function! StatuslineClearCacheFugitive(bufname)
  if !exists('*FugitiveReal')
    return
  endif
  let bufnr = bufnr(FugitiveReal())
  if bufnr != -1
    call StatuslineClearCache(bufnr)

    " Clear caches on / update alternative window(s).
    " https://github.com/tomtom/quickfixsigns_vim/issues/67
    let idx = 0
    let prev_alt_winnr = winnr('#')
    let prev_winnr = winnr()
    for b in tabpagebuflist()
      let idx += 1
      if b == bufnr
        exe 'noautocmd '.idx.'wincmd w'
        QuickfixsignsSet
      endif
    endfor
    if winnr() != prev_winnr || winnr('#') != prev_alt_winnr
        exe 'noautocmd '.prev_alt_winnr.'wincmd w'
        exe 'noautocmd '.prev_winnr.'wincmd w'
    endif
  endif
endfunction

function! StatuslineClearCache(...)
  let bufnr = a:0 ? a:1 : bufnr('%')
  if exists('*quickfixsigns#vcsdiff#ClearCache')
    call quickfixsigns#vcsdiff#ClearCache(bufnr)
  endif
  call setbufvar(bufnr, 'stl_cache_hunks', 'UNSET')
  call setbufvar(bufnr, 'stl_cache_fugitive', [0, ''])
endfun

function! OnNeomakeCountsChanged()
  let [ll_counts, qf_counts] = GetNeomakeCounts(g:neomake_hook_context.bufnr, 0)
  let cmd = ''
  let file_mode = get(get(g:, 'neomake_hook_context', {}), 'file_mode')
  " let file_mode = get(get(g:, 'neomake_current_maker', {}), 'file_mode')
  if file_mode
    for [type, c] in items(ll_counts)
      if type ==# 'E'
        let cmd = 'lwindow'
        break
      endif
    endfor
  else
    for [type, c] in items(qf_counts)
      if type ==# 'E'
        let cmd = 'cwindow'
        break
      endif
    endfor
  endif
  if cmd !=# ''
    let aw = winnr('#')
    let pw = winnr()
    exec cmd
    if winnr() != pw
      " Go back, maintaining the '#' window.
      exec 'noautocmd ' . aw . 'wincmd w'
      exec 'noautocmd ' . pw . 'wincmd w'
    endif
  else
  endif
endfunction

function! OnNeomakeFinished()
  " Close empty lists.
  " echom 'statusline: OnNeomakeFinished'
  if g:neomake_hook_context.file_mode
    if len(getloclist(0)) == 0
      lwindow
    endif
  else
    if len(getqflist()) == 0
      cwindow
    endif
  endif
  " XXX: brute-force
  call s:RefreshStatus()
endfunction

augroup stl_neomake
  au!
  " autocmd User NeomakeMakerFinished unlet! b:stl_cache_neomake
  " autocmd User NeomakeListAdded unlet! b:stl_cache_neomake
  autocmd User NeomakeCountsChanged call OnNeomakeCountsChanged()
  autocmd User NeomakeFinished call OnNeomakeFinished()
  " autocmd User NeomakeMakerFinished call OnNeomakeMakerFinished()
augroup END

function! s:setup_autocmds()
  augroup vimrc_statusline
    au!
    " au WinEnter * setlocal statusline=%!MyStatusLine('active')
    " au WinLeave * setlocal statusline=%!MyStatusLine('inactive')

    au InsertEnter * call StatuslineModeColor(v:insertmode)
    " TODO: typically gets called for both InsertLeave and TextChanged?!
    " BufWinEnter for when going to a tag etc to another buffer in the same win.
    au InsertLeave,TextChanged,BufWritePost,ShellCmdPost,ShellFilterPost,BufWinEnter,WinEnter * call StatuslineModeColor('')

    au TextChanged,BufWritePost,ShellCmdPost,ShellFilterPost,FocusGained * call StatuslineClearCache()
    " Invalidate cache for corresponding buffer for a fugitive buffer.
    au BufWritePost fugitive:///* call StatuslineClearCacheFugitive(expand('<amatch>'))

    " au Syntax * call StatuslineHighlights()
    au ColorScheme * call StatuslineHighlights('ColorScheme')
    au VimEnter * call StatuslineHighlights('VimEnter')

    autocmd VimEnter,WinEnter,BufWinEnter * call <SID>RefreshStatus()
  augroup END
endfunction
call s:setup_autocmds()

call StatuslineHighlights()  " Init, also for reloading vimrc.

function! StatuslineQfLocCount(winnr, ...)
  let bufnr = a:0 ? a:1 : winbufnr(a:winnr)
  let r = {}
  let loclist = getloclist(a:winnr)
  let loclist_for_buffer = copy(loclist)
  if bufnr isnot# 0
    call filter(loclist_for_buffer, 'v:val.bufnr == '.bufnr)
  endif
  " if len(loclist) && !len(loclist_for_buffer)
  "   echom "Ignoring loclist for different buffer (copied on split)" bufnr
  " endif
  for [type, list] in [['ll', loclist_for_buffer], ['qf', getqflist()]]
    let list_len = len(list)
    let valid_len = list_len ? len(filter(copy(list), 'v:val.valid == 1')) : 0
    let r[type] = [list_len, valid_len]
  endfor
  return r
endfunction

function! s:has_localdir(winnr)
  if exists('s:has_localdir_with_winnr')
    let args = get(s:, 'has_localdir_with_winnr', 1) ? [a:winnr] : []
    return call('haslocaldir', args)
  endif
  try
    let r = haslocaldir(a:winnr)
    let s:has_localdir_with_winnr = 1
    return r
  catch /^Vim\%((\a\+)\)\=:\(E15\|E118\)/
    let s:has_localdir_with_winnr = 0
    return haslocaldir()
  endtry
endfunction


function! MyStatusLine(winnr, active)
  if a:active && a:winnr != winnr()
    " Handle :only for winnr() > 1: there is no (specific) autocommand, and
    " none when window 1+2 are the same buffer.
    call <SID>RefreshStatus()
    return
  endif
  let mode = mode()
  let winwidth = winwidth(0)
  let bufnr = winbufnr(a:winnr)
  let modified = getbufvar(bufnr, '&modified')
  let ft = getbufvar(bufnr, '&ft')
  let readonly_flag = getbufvar(bufnr, '&readonly') && ft !=# 'help' ? ' ‼' : ''

  " Neomake status.
  if exists('*neomake#statusline#get')
    let neomake_status_str = neomake#statusline#get(bufnr, {
          \ 'format_running': '… ({{running_job_names}})',
          \ 'format_ok': (a:active ? '%#NeomakeStatusGood#' : '%*').'✓',
          \ 'format_quickfix_ok': '',
          \ 'format_quickfix_issues': (a:active ? '%s' : ''),
          \ 'format_status': '%%(%s'
          \   .(a:active ? '%%#StatColorHi2#' : '%%*')
          \   .'%%)',
          \ })
  else
    let neomake_status_str = ''
    if exists('*neomake#GetJobs')
      if exists('*neomake#config#get_with_source')
        " TODO: optimize! gets called often!
        let [disabled, source] = neomake#config#get_with_source('disabled', -1, {'bufnr': bufnr})
        if disabled != -1
          if disabled
            let neomake_status_str .= source[0].'-'
          else
            let neomake_status_str .= source[0].'+'
          endif
        endif
      endif
      let neomake_status_str .= '%('.StatuslineNeomakeStatus(bufnr, '…', '✓')
            \ . (a:active ? '%#StatColorHi2#' : '%*')
            \ . '%)'
    endif
  endif

  let bt = getbufvar(bufnr, '&buftype')
  let show_file_info = a:active && bt ==# ''

  " Current or next/prev conflict markers.
  let conflict_status = ''
  if show_file_info
    if getbufvar(bufnr, 'stl_display_conflict', -1) == -1
      call setbufvar(bufnr, 'stl_display_conflict', s:display_conflict_default())
    endif
    if getbufvar(bufnr, 'stl_display_conflict')
      let info = StatuslineGetConflictInfo()
      if len(info) && len(info.text)
        let text = info.text
        if info.current_conflict >= 0
          let text .= ' (#'.(info.current_conflict+1).')'
        endif
        let conflict_count = (info.current_conflict >= 0
              \ ? (info.current_conflict+1).'/' : '')
              \ .len(info.conflicts)
        if !len(info.conflicts)
          let conflict_count .= '('.len(info.marks).')'
        endif
        let conflict_info = conflict_count.' '.text
        let conflict_status = '[䷅ '.conflict_info.']'
        " TODO: use function (from Neomake?!) to not cause hit-enter prompt.
        " TODO: should not include hilight groups.
        " redraw
        " echo conflict_info
      endif
    endif
  endif
  let use_cache = (
        \ ft !=# 'qf'
        \ && (!getbufvar(bufnr, 'git_dir')
        \     || (getbufvar(bufnr, 'stl_cache_hunks') !=# 'UNSET'
        \         && getbufvar(bufnr, 'stl_cache_fugitive', [0, ''])[0]))
        \ )

  if show_file_info
    let has_localdir = s:has_localdir(a:winnr)
  endif
  let cwd = getcwd()

  if use_cache
    let cache_key = [a:winnr, a:active, bufnr, modified, ft, readonly_flag, mode, winwidth, &paste, conflict_status, neomake_status_str, cwd]
    if show_file_info
      let cache_key += [has_localdir]
    endif
    let win_cache = getwinvar(a:winnr, 'stl_cache', {})
    let cache = get(win_cache, mode, [])
    if len(cache) && cache[0] == cache_key
      return cache[1]
    endif
  endif
  " let active = a:winnr == winnr()

  if modified
    if a:active
      let r = '%#StatColorModified#'
    else
      let r = '%#StatColorModifiedNC#'
    endif
  elseif a:active
    let r = '%#StatColorMode#'
  " elseif ft ==# 'qf'
  "   let r = '%#StatusLineQuickfixNC#'
  else
    let r = '%#StatusLineNC#'
  endif

  let r .= ' '  " nbsp for underline style

  let part1 = ''
  let part2 = []

  if bt !=# ''
    if ft ==# 'qf'
      " TODO: rely on b:isLoc directly?!
      let isLoc = My_get_qfloclist_type(bufnr) ==# 'll'
      let part1 .= isLoc ? '[ll]' : '[qf]'
      " Get title, removing default names.
      let qf_title = substitute(getwinvar(a:winnr, 'quickfix_title', ''), '\v:(setloclist|getqflist)\(\)|((cgetexpr|lgetexpr).*$)', '', '')
      " trim
      if len(qf_title)
        if qf_title[0] ==# ':'
          let qf_title = qf_title[1:-1]
        endif
        let qf_title = substitute(qf_title, '^\_s*\(.\{-}\)\_s*$', '\1', '')
        if len(qf_title)
          let max_len = float2nr(round(&columns/3))
          if len(qf_title) > max_len
            let part1 .= ' '.qf_title[0:max_len].'…'
          else
            let part1 .= ' '.qf_title
          endif
          let part1 .= ' '
        endif
      endif

      let [list_len, valid_len] = StatuslineQfLocCount(a:winnr, 0)[isLoc ? 'll' : 'qf']
      if valid_len != list_len
        let part1 .= '('.valid_len.'['.list_len.'])'
      else
        let part1 .= '('.list_len.')'
      endif

      " if part2 == ' '
      "   let part2 .= bufname('#')
      " endif
    endif
  elseif ft ==# 'startify'
    let part1 = '[startify]'
  endif
  if part1 ==# ''
    " Shorten filename while reserving 30 characters for the rest of the statusline.
    " let fname = "%{ShortenFilename('%', winwidth-30)}"
    let fname = ShortenFilename(bufname(bufnr), winwidth-30, cwd)
    " let ext = fnamemodify(fname, ':e')
    let part1 .= fname
  endif

  let r .= part1

  if modified
    let r .= '[+]'
  endif
  let r .= readonly_flag

  if show_file_info
    let git_dir = getbufvar(bufnr, 'git_dir', '')
    if git_dir !=# ''
      if exists('*quickfixsigns#vcsdiff#GetHunkSummary')
        let stl_cache_hunks = getbufvar(bufnr, 'stl_cache_hunks', 'UNSET')
        if stl_cache_hunks ==# 'UNSET'
          let hunks = quickfixsigns#vcsdiff#GetHunkSummary()
          if len(hunks)
            let stl_cache_hunks = join(filter(map(['+', '~', '-'], 'hunks[v:key] > 0 ? v:val.hunks[v:key] : 0'), 'v:val isnot 0'))
            call setbufvar(bufnr, 'stl_cache_hunks', stl_cache_hunks)
          endif
        endif
        if len(stl_cache_hunks)
            let part2 += [stl_cache_hunks]
        endif
      endif

      if exists('*fugitive#head')
        let git_ftime = getftime(git_dir)
        let stl_cache_fugitive = getbufvar(bufnr, 'stl_cache_fugitive', [0, ''])
        if stl_cache_fugitive[0] != git_ftime
          let stl_cache_fugitive = [git_ftime, '']

          " NOTE: the commit itself is in the "filename" already.
          let fug_head = fugitive#head(40)
          if fug_head =~# '^\x\{40\}$'
            let output = systemlist('git --git-dir='.shellescape(git_dir).' name-rev --name-only '.shellescape(fug_head))
            if len(output)
              let stl_cache_fugitive[1] = output[0]
              if stl_cache_fugitive[1] ==# 'undefined'
                let stl_cache_fugitive[1] = fug_head[0:6]
              endif
            else
              let stl_cache_fugitive[1] = ''
            endif
          else
            let stl_cache_fugitive[1] = fug_head
          endif
          " let fug_commit = fugitive#buffer().commit()
          " if fug_commit != ''
          "   let named = systemlist(['git', 'name-rev', '--name-only', fug_commit])
          "   let stl_cache_fugitive = fug_commit[0:7] . '('.fugitive#head(7).')'
          " else
          "   let stl_cache_fugitive = fugitive#head(7)
          " endif
          call setbufvar(bufnr, 'stl_cache_fugitive', stl_cache_fugitive)
        endif
        let part2 += [' '.stl_cache_fugitive[1]]
      endif
    endif

    if has_localdir
      let part2 += ['[lcd]']
    endif
  endif

  if modified && !a:active
    let r .= ' %#StatusLineNC#'
  endif

  " if len(part2)
    if a:active
      " Add space for copy'n'paste of filename.
      let r .= ' %#StatColorHi1To2#'
      let r .= ''
      let r .= '%#StatColorHi2#'
    else
      let r .= '  '
    endif
  " elseif a:active
  "   " let r .= '%#StatColorHi1ToBg#'
  "   let r .= '%#StatColorHi2#'
  " endif

  let r .= '%<'  " Cut off here, if necessary.

  if len(part2)
    let r .= ' '.join(part2).' '
    " if a:active
    "   let r .= '%#StatColorHi2ToBg#'
    " endif
  endif

  " if a:active
  "   let r .= ""
  "   let r .= '%#StatusLine#'
  "   let r .= '%*'
  " else
  "   let r .= ' '
  " endif

  let r .= '%( ['

  " let r .= '%Y'      "filetype
  let r .= '%H'      "help file flag
  let r .= '%W'      "preview window flag
  let r .= '%{&ff=="unix"?"":",".&ff}'  "file format (if !=unix)
  let r .= '%{strlen(&fenc) && &fenc!="utf-8"?",".&fenc:""}' "file encoding (if !=utf-8)
  let r .= '] %)'

  " Right part.
  let r .= '%='
  " if a:active
  "   let r .= '%#StatColorHi2ToBg#'
  "   let r .= ''
  "   let r .= '%#StatColorHi2#'
  " endif
  " let r .= '%b,0x%-8B ' " Current character in decimal and hex representation
  " let r .= ' %{FileSize()} '  " size of file (human readable)

  let r .= conflict_status

  let r .= neomake_status_str

  " General qf/loclist counts.
  " TODO: only if not managed by Neomake?!
  " TODO: detect/handle grepper usage?!
  " TODO: display qf info in tabline?!
  if a:active && ft !=# 'qf'
    for [list_type, counts] in items(StatuslineQfLocCount(a:winnr, bufnr))
      let [list_len, valid_len] = counts
      if list_len
        " let r .= ' ' . (list_type == 'll' ? 'L☰ ' : 'Q☰ ') . valid_len
        " let r .= ' ' . (list_type == 'll' ? 'L⋮' : 'Q⋮') . valid_len
        let r .= ' ' . (list_type ==# 'll' ? 'L≡' : 'Q≡') . valid_len
        " let r .= ' '.qfloc_type.':'.valid_len
        if valid_len != list_len
          let r .= '['.list_len.']'
        endif
        " let r .= ']'
      endif
    endfor
  endif

  " XXX: always on 2nd level on the right side.
  " if a:active
  "   let r .= '%#StatColorHi1To2Normal#'
  "   let r .= ''
  "   let r .= '%#StatColorHi1#'
  " else
  "   let r .= '%*'
  " endif

  if bufname(bufnr) ==# ''
    if ft !=# ''
      if index(['qf', 'startify'], ft) == -1
      "   let r .= '['.(isLoc ? 'll' : 'qf').']'
      " else
        let r .= '['.ft.']'
      endif
    endif
  elseif ft ==# ''
    let r .= '[no ft]'
  endif

  if a:active && &paste
    let r .= ' %#StatColorHi2Bold#[P]%#StatColorHi2#'
  endif

  " " let r .= ' %-12(L%l/%L:C%c%V%) ' " Current line and column
  " if !&number && !&relativenumber
    let r .= ' %l:%2v' " Current line and (virtual) column, %c is bytes.
  " endif
  " " let r .= '%l/%L'   "cursor line/total lines
  " " let r .= ' %P'    "percent through file
  " let r .= ' %2p%%'    "percent through file

  " let r .= ' [%n@%{winnr()}]'  " buffer and windows nr
  let r .= ' [%n.'.a:winnr  " buffer and windows nr
  if tabpagenr('$') > 1
    let r .= '.'.tabpagenr()
  endif
  let r .= ']'

  " let errors = ''
  " if exists('*neomake#statusline#LoclistStatus')
  "   let errors = neomake#statusline#LoclistStatus()
  "   if errors == ''
  "     let errors = neomake#statusline#QflistStatus()
  "   endif
  "   if errors != ''
  "     " let r .= '%('
  "     let r .= '%#StatColorHi1ToError#'
  "     let r .= '%#StatColorError#'
  "     let r .= ' '.errors.' '
  "   endif
  " endif

  if use_cache
    let win_cache[mode] = [cache_key, r]
    call setwinvar(a:winnr, 'stl_cache', win_cache)
  endif
  return r
endfunction


unlockvar s:empty_conflict_cache
let s:empty_conflict_cache = {
      \ 'conflicts': [],
      \ 'marks': [],
      \ 'part_begin_marks': [],
      \ 'end_marks': [],
      \ 'current_conflict': -1,
      \ }
lockvar s:empty_conflict_cache

function! s:display_conflict_default(...)
  " _MY_HAS_GIT_CONFLICTS gets set in the shell theme (+vi-git-unmerged).
  return expand($_MY_HAS_GIT_CONFLICTS) || getwinvar(a:0 ? a:1 : winnr(), '&diff')
endfunction

function! StatuslineToggleConflictInfo()
  let b:stl_display_conflict = !get(b:, 'stl_display_conflict', s:display_conflict_default())
  if &verbose
    echom b:stl_display_conflict ? 'Enabled.' : 'Disabled.'
  endif
  unlet! b:stl_cache_conflict
endfunction
command! StatuslineToggleConflictInfo call StatuslineToggleConflictInfo()

function! s:get_marker_desc(line)
  let line = a:line[8:-1]
  if !len(line)
    return a:line[0:2]
  endif
  if line =~# '^\x\{40\}$'
    let line = line[0:7]
  endif
  return a:line[0].' '.line
endfunction

function! StatuslineGetConflictInfo()
  let prev_cursor = getcurpos()
  lockvar prev_cursor
  try
    let mark_all = '\m^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)'
    let mark_start = '\m^<\{7}<\@!'
    let mark_part_begin = '\m^\(@@ .* @@\|[<=|]\{7}[<=|]\@!\)'
    let mark_end = '\m>\{7}>\@!'

    if !exists('b:stl_cache_conflict')
      let b:stl_cache_conflict = [0, deepcopy(s:empty_conflict_cache)]
    endif
    if b:stl_cache_conflict[0] == b:changedtick
      let r = b:stl_cache_conflict[1]
    else
      let r = deepcopy(s:empty_conflict_cache)
      " Count conflicts and marks.
      " TODO: use this data (more) instead of searching again below.
      call cursor(1, 1)
      while search(mark_all, 'cW')
        let linenr = line('.')
        let line = getline('.')
        let type = line[0]
        if type ==# '>'
          " let r.end_marks += [linenr]
          call insert(r.end_marks, linenr, 0)
        else
          " index(["<", "|", "="], v:val[1]) != -1')
          call insert(r.part_begin_marks, linenr, 0)
          if type ==# '<'
            let r.conflicts += [linenr]
          endif
        endif
        let r.marks += [[linenr, type]]
        if linenr == line('$')
          break
        endif
        call cursor(linenr + 1, 1)
      endwhile
      let b:stl_cache_conflict = [b:changedtick, r]
    endif

    if !len(r.marks)
      return {}
    endif
    " redir => count_marks
    "   silent exe '%s/'.mark_all.'//gne'
    " redir END
    " let count_marks=matchstr(count_marks, '\d\+')

    " Restore cursor for search below, but use column 1.
    call setpos('.', map(copy(prev_cursor), 'v:key == 2 ? 1 : v:val'))
    let linenr = line('.')

    let disp_hunk = ''
    " Use already searched info.
    " let end_marks = map(filter(copy(r.marks), 'v:val[1] == ">"'), 'v:val[0]')
    " let part_begin_marks = map(filter(copy(r.marks), 'index(["<", "|", "="], v:val[1]) != -1'), 'v:val[0]')

    let prev_end = 0
    for l in r.end_marks
      if l < linenr
        let prev_end = l
        break
      endif
    endfor
    " let prev_end = get(filter(copy(end_marks), 'v:val < linenr'), -1)
    " let prev_end = search(mark_end, 'bnW')
    let part_begin = 0
    for l in r.part_begin_marks
      if l > prev_end && l <= linenr
        let part_begin = l
        break
      endif
    endfor
    " let part_begin = get(filter(copy(part_begin_marks), 'v:val <= linenr && v:val > prev_end'), -1)
    " let part_begin = search(mark_part_begin, 'bcnW', prev_end)
    if part_begin && getline(part_begin)[0] ==# '<'
      let conflict_start = part_begin
    else
      " let conflict_start = search(mark_start, 'bcnW', prev_end)
      let conflict_start = get(filter(copy(r.conflicts), 'v:val > prev_end && v:val <= linenr'), -1)
    endif
    " echom prev_end "/" part_begin "/" conflict_start "/" part_begin
    if conflict_start
      let r.current_conflict = index(r.conflicts, conflict_start)
      " Get special end for "=======" block.
      if match(getline(part_begin), '\m^========\@!') != -1
        let conflict_end = search(mark_end, 'cW')
        let part_end = conflict_end
        let hunk_desc = conflict_end ? conflict_end : part_begin
      else
        let part_end = search(mark_all, 'W')
        let conflict_end = search(mark_end, 'cW')
        let hunk_desc = part_begin
      endif
      let hunk_desc = s:get_marker_desc(getline(hunk_desc))

      if part_end
        let disp_hunk = '%#StatColorHi2Bold#'.hunk_desc.'%#StatColorHi2#'
        " Display info with length of each hunk part.
        let prev_lengths = []
        if conflict_start
          let l = conflict_end
          let found_cur = 0
          for m in ['=', '|', '<']
            let new_l = search('\m^'.m.'\{7}'.m.'\@!', 'bW', conflict_start)
            if new_l != l
              if !found_cur && prev_cursor[1] >= new_l && prev_cursor[1] <= l
                let prev_lengths += ['%#StatColorHi2Bold#'.m.''.(l - new_l - 1).'%#StatColorHi2#']
                let found_cur = 1
              else
                let prev_lengths += [m.''.(l - new_l - 1)]
              endif
            endif
            let l = new_l
          endfor
        endif
        if len(prev_lengths)
          let disp_hunk .= ' ('.join(reverse(prev_lengths), ' ').')'
        else
          let disp_hunk .= ' ('.(part_end-part_begin-1).')'
        endif
      else
        let disp_hunk = 'in: '.hunk_desc
      endif
    else
      let r.current_conflict = -1
    endif
    if disp_hunk is# ''
      " let prev_cursor = getcurpos()
      let cline = prev_cursor[1]
      " call cursor(line('w$'), 0)

      let next_mark = search(mark_all, 'nW')
      let stop_prev = next_mark ? next_mark - cline : 0
      let prev_mark = search(mark_all, 'bcnW', 0)
      if prev_mark && !next_mark
        let disp_hunk = '-'.(cline - prev_mark).':'.s:get_marker_desc(getline(prev_mark))
      elseif next_mark
        let disp_hunk = '+'.(next_mark - cline).':'.s:get_marker_desc(getline(next_mark))
      endif

      call setpos('.', prev_cursor)
    endif
    if disp_hunk isnot# ''
      let r.text = disp_hunk
    endif
    return r
  finally
    call setpos('.', prev_cursor)
  endtry
endfunction


function! StatuslineDisable()
  augroup vimrc_statusline
    au!
  augroup END
  let s:enabled = 0
  call s:RefreshStatus()
endfunction
command! StatuslineDisable call StatuslineDisable()

function! StatuslineEnable()
  let s:enabled = 1
  call s:setup_autocmds()
endfunction
command! StatuslineEnable call StatuslineEnable()

function! GetNeomakeCounts(bufnr, use_cache)
  " let bufnr = a:bufnr == 0 ? winbufnr(0) : a:bufnr
  let stl_cache_neomake = a:use_cache ? getbufvar(a:bufnr, 'stl_cache_neomake', []) : []
  if !len(stl_cache_neomake)
    " try
    "   let loclist_counts = neomake#statusline#LoclistCounts(a:winnr)
    " catch E118  " too many args
      let loclist_counts = neomake#statusline#LoclistCounts(a:bufnr)
    " endtry
    let qf_errors = neomake#statusline#QflistCounts()
    let stl_cache_neomake = [loclist_counts, qf_errors]
    call setbufvar(a:bufnr, 'stl_cache_neomake', stl_cache_neomake)
  endif
  return stl_cache_neomake
endfunction

function! StatuslineNeomakeCounts(bufnr, ...)
  let include = a:0 ? a:1 : []
  let exclude = a:0 > 1 ? a:2 : []
  let empty = a:0 > 2 ? a:3 : ''

  let [loclist_counts, qf_errors] = GetNeomakeCounts(a:bufnr, 1)
  " echom 'loclist_counts' string(loclist_counts)

  let errors = []
  for [type, c] in items(loclist_counts)
    if len(include) && index(include, type) == -1 | continue | endif
    if len(exclude) && index(exclude, type) != -1 | continue | endif
    " echom "type, c" string(type) string(c)
    let errors += [type . ':' .c]
  endfor
  if ! empty(qf_errors)
    for [type, c] in items(qf_errors)
      if len(include) && index(include, type) == -1 | continue | endif
      if len(exclude) && index(exclude, type) != -1 | continue | endif
      let errors += [type . ':' .c]
    endfor
  endif
  if len(errors)
    return ' '.join(errors).' '
  endif
  return empty
endfunction

let s:neomake_stl_cache = {}
function! StatuslineNeomakeStatus(bufnr, ...)
  let jobs = neomake#GetJobs()
  let cache_key = [neomake#GetStatus().last_make_id, len(jobs)]
  let cached = get(s:neomake_stl_cache, a:bufnr, [[-1, -1], ''])
  if cached[0] == cache_key
    return cached[1]
  endif

  let running = ''
  for j in jobs
    if j.bufnr == a:bufnr
      let running = a:0 ? a:1 : '…'
      break
    endif
  endfor

  if running !=# ''
    let r = running
  else
    let good = StatuslineNeomakeStatusGood(a:bufnr)
    if good !=# ''
      let r = a:0 > 1 ? a:2 : '✓'
    else
      let r = ''
      let errors = StatuslineNeomakeCounts(a:bufnr, ['E'])
      if len(errors)
        let r .= '%#StatColorNeomakeError#'.errors
      endif
      let nonerrors = StatuslineNeomakeCounts(a:bufnr, [], ['E'])
      if len(nonerrors)
        let r .= '%#StatColorNeomakeNonError#'.nonerrors
      endif
    endif
  endif
  let s:neomake_stl_cache[a:bufnr] = [cache_key, r]
  return r
endfunction

function! StatuslineNeomakeStatusGood(bufnr, ...)
  if StatuslineNeomakeCounts(a:bufnr) ==# ''
    return a:0 > 1 ? a:2 : '✓'
  endif
  return ''
endfunction
"}}}1

" (gui)tablabel {{{
let s:tablabel_cache = {}
augroup statusline_tabline_clear_cache
  au!
  " To reset modified flag.
  " au BufWritePost * unlet! t:_my_tablabel_cache
  " au BufWritePost * unlet! s:tablabel_cache[tabpagenr()]
  au BufWritePost * unlet! w:stl_cache
  " au BufWinEnter  * unlet! w:stl_cache
augroup END

" TODO: ensure that the current tab gets displayed, i.e. by shortening other
" labels then.
function! TabLabel(tabnr, current)
  " let cwd = a:0 ? a:1 : getcwd()
  let cwd = getcwd()
  let wincount = tabpagewinnr(a:tabnr, '$')
  let tabpagewinnr = tabpagewinnr(a:tabnr)

  " Add '+' for each modified buffer in a window.
  let modified = ''
  let bufnrlist = tabpagebuflist(a:tabnr)
  let uniq_bufnrlist = uniq(sort(copy(bufnrlist)))
  for bufnr in uniq_bufnrlist
    if getbufvar(bufnr, '&modified')
      let modified .= '+'
    endif
  endfor

  let cache_key = join([a:current, cwd, wincount, tabpagewinnr, modified] + uniq_bufnrlist, '-')
  " let cached = gettabvar(a:tabnr, '_my_tablabel_cache', [])
  " let cached = get(get(s:tablabel_cache, a:tabnr, {}), cache_key, '')
  if !exists('s:tablabel_cache[a:tabnr]')
    let s:tablabel_cache[a:tabnr] = {}
  elseif exists('s:tablabel_cache[a:tabnr][cache_key]')
    return s:tablabel_cache[a:tabnr][cache_key]
  endif

  let suffix = (a:current ? 'Sel' : '')
  let label = '%#TabLineNumber'.suffix.'#'.a:tabnr

  " Append the number of windows in the tab page if more than one
  if wincount > 1
    let label .= '.'.wincount
  endif
  let label .= ':'
  let label .= '%#TabLine'.suffix.'#'

  let label .= modified

  " Append the buffer name
  " let label .= fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]), ':~:.')
  let label .= ShortenFilename(bufnrlist[tabpagewinnr - 1], 20, cwd)

  if a:current
    try
      let win_cwd = getcwd(0, a:tabnr)
      if win_cwd != getcwd(-1, a:tabnr)
        " TODO: different highlight?!
        let label .= ' (@' . ShortenFilename(win_cwd).')'
      endif
    catch /^Vim\%((\a\+)\)\=:\(E15\|E118\)/
    endtry
  endif
  " https://github.com/vim/vim/issues/1317
  " call settabvar(a:tabnr, '_my_tablabel_cache', [cache_key, label])

  if len(s:tablabel_cache[a:tabnr]) > tabpagenr('$')
    let s:tablabel_cache[a:tabnr] = {}
  endif
  let s:tablabel_cache[a:tabnr][cache_key] = label
  return label
endfunction
function! GuiTabLabel()
  return TabLabel(v:lnum, tabpagenr() == v:lnum)
endfunction
set guitablabel=%{GuiTabLabel()}
" }}}

" tabline {{{
function! Tabline()
  let s = ''
  let curtabnr = tabpagenr()
  let tabcount = tabpagenr('$')
  try
    let tabcwd = getcwd(-1, curtabnr)
  catch /^Vim\%((\a\+)\)\=:\(E15\|E118\)/
    let tabcwd = getcwd()
  endtry

  for i in range(tabcount)
    let tab = i + 1
    " let winnr = tabpagewinnr(tab)
    " let buflist = tabpagebuflist(tab)
    " let bufnr = buflist[winnr - 1]
    " let bufname = bufname(bufnr)
    " let bufmodified = getbufvar(bufnr, "&mod")

    " let s .= '%' . tab . 'T'
    " let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    " let s .= ' ' . tab .':'
    " let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . ' ' : '[No Name] ')
    " if bufmodified
    "   let s .= '[+] '
    " endif

    let s .= '%' . tab . 'T'
    " let s .= (tab == tabpagenr() ? '%#TabLineSelSign#%#TabLineSel#' : ' ')
    let s .= (tab == curtabnr ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . TabLabel(tab, tab == curtabnr) . ' '
    " let s .= (tab == tabpagenr() ? '%#TabLineSelSign#%#TabLine#' : ' ')
    let s .= (tab == curtabnr ? '%#TabLine#' : '')
    " let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . '] ' : '[No Name] ')
    " if bufmodified
    "   let s .= '[+] '
    " endif
  endfor

  " let s .= ' %#TabLineFill#'
  let s .= '%=%#TabLineFill#%999X'
  let maxlen = &columns / (tabcount+1)
  let s .= '%#TabLineCwd#['.ShortenFilename(tabcwd, maxlen).']'

  " TODO: cache?!
  if exists('*ObsessionStatus')
    let s .= ObsessionStatus()
  endif
  return s
endfunction
set tabline=%!Tabline()
" }}}1

" vim: iskeyword-=#
