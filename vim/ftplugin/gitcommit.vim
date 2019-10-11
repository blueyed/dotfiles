" Setup windows for Git commit message editing.
" It scrolls to "Changes" in the buffer, splits the window etc.
" This allows for reviewing the diff (from `git commit -v`) while editing the
" commit message easily.
if has_key(b:, 'b:fugitive_commit_arguments')
      \ || get(b:, 'fugitive_type', '') !=# 'index'  " Skip with fugitive :Gstatus
  if !(tabpagenr('$') == 1 && winnr('$') == 1)
    " Only with single windows (for Q mapping at least).
    finish
  endif
  let b:my_auto_scrolloff=0
  setlocal foldmethod=syntax foldlevel=1 nohlsearch spell spl=de,en sw=2 scrolloff=0

  augroup vimrc_gitcommit
    autocmd BufWinEnter <buffer>
          \ exe 'keeppatterns g/^# \(Changes not staged\|Untracked files\)/norm! zc'
          \ | silent! exe 'keeppatterns ?^# Changes to be committed:'
          \ | exe 'norm! zt'
          \ | belowright exe max([5, min([10, (winheight(0) / 3)])]).'split'
          \ | exe 'normal! gg'
          \ | if has('vim_starting') | exe 'autocmd VimEnter * nested 2wincmd w' | endif
          \ | exe 'augroup vimrc_gitcommit | exe "au!" | augroup END'
          \ | map <buffer> Q :qall<CR>
  augroup END
endif
