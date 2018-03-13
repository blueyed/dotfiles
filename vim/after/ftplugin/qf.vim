" Generic wrapper, should replace s:MyQuickfixCR
function! s:with_equalalways(cmd)
  try
    let winid = win_getid()
  catch
    let winid = -1
  endtry

  try
    exe a:cmd
  catch /:E36:/
    if !&equalalways
      set equalalways
      try
        exe a:cmd
      finally
        set noequalalways
      endtry
    endif
  endtry

  if winid != -1
    " Used in MyQuitWindow().
    let w:my_prev_winid = winid
  endif
endfunction

function! s:open_in_prev_win()
  " does not contain line number
  let cfile = expand('<cfile>')
  let f = findfile(cfile)
  if !len(f)
    echom 'Could not find file at cursor ('.cfile.')'
    return
  endif

  " Delegate to vim-fetch.  Could need better API
  " (https://github.com/kopischke/vim-fetch/issues/13).
  let f = expand('<cWORD>')
  wincmd p
  silent exe 'e' f
endfunction

nmap <buffer> o :call <SID>open_in_prev_win()<cr>
nmap <buffer> gf :call <SID>with_equalalways('wincmd F')<cr>
nmap <buffer> gF :call <SID>with_equalalways('wincmd gF')<cr>
nmap <buffer> <c-w><cr> :call <SID>with_equalalways('call feedkeys("<Bslash><lt>c-w><Bslash><lt>cr>", "nx")')<cr>

" nmap <buffer> gf try :wincmd p \| norm gF<cr>
" nmap <buffer> gF :tab sp \| norm gF<cr>

" Workaround for https://github.com/vim/vim/issues/908.
" NOTE: could use s:with_equalalways maybe, but needs to save and execute
" the previous CR mapping.
let s:cr_map = ':call <SID>MyQuickfixCR()<cr>'
let s:cr_map_match = ':call <SNR>\d\+_MyQuickfixCR()<CR>'
if !exists('*s:MyQuickfixCR')
  " prevent E127: Cannot redefine function %s: It is in use" (likely when using this function triggers a new qf list (e.g. via Neomake))
function! s:MyQuickfixCR()
  let bufnr = bufnr('%')
  " if !bufexists(bufnr)
  "   " Might happen with jedi-vim's goto-window, which closes itself on
  "   " WinLeave.
  "   return
  " endif
  let prev_map = "\<Plug>MyQuickfixCRPre"

  " Remove our mapping.
  exe 'nunmap <buffer> <cr>'
  try
    call feedkeys(prev_map, 'x')
  catch /:E36:/
    set equalalways
    try
      call feedkeys(prev_map, 'x')
    finally
      set noequalalways
    endtry
  finally
    if !bufexists(bufnr)
      " Might happen with jedi-vim's goto-window, which closes itself on
      " WinLeave.
      return
    endif
    if bufnr('%') == bufnr
      exe 'nmap <buffer> <cr> '.s:cr_map
      " call SetupMyQuickfixCR()
      " map <buffer> <cr> :call MyQuickfixCR()<cr>
    else
      " Setup autocmd to re-setup our mapping.
      augroup myquickfixcr
        exe 'au! * <buffer'.bufnr.'>'
        " au! WinEnter <buffer> call SetupMyQuickfixCR()
        exe 'au! WinEnter <buffer='.bufnr.'> exe "nmap <buffer> <cr> ".s:cr_map | au! myquickfixcr'
      augroup END
    endif
  endtry
endfunction
endif

function! SetupMyQuickfixCR()
  if maparg('<cr>', 'n') =~# s:cr_map_match
    " Already setup, don't do it twice.
    return
  endif
  let prev_map = maparg('<cr>', 'n')
  if !len(prev_map)
    let prev_map = "\<CR>"
  endif
  exe 'nmap <buffer> <Plug>MyQuickfixCRPre '.prev_map
  exe 'nmap <buffer> <cr> '.s:cr_map
  exe 'nmap <buffer> ,xy '.s:cr_map
endfunction
call SetupMyQuickfixCR()
