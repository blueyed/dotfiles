" Setup windows for Git commit message editing.
" It scrolls to "Changes" in the buffer, splits the window etc.
" This allows for reviewing the diff (from `git commit -v`) while editing the
" commit message easily.
if get(b:, 'fugitive_type', '') !=# 'index'  " Skip with fugitive :Gstatus
  let b:my_auto_scrolloff=0
  setlocal foldmethod=syntax foldlevel=1 nohlsearch spell spl=de,en sw=2 scrolloff=0

  augroup vimrc_gitcommit
    autocmd BufWinEnter <buffer>
          \ exe 'g/^# \(Changes not staged\|Untracked files\)/norm! zc'
          \ | silent! exe '?^# Changes to be committed:'
          \ | exe 'norm! zt'
          \ | belowright exe max([5, min([10, (winheight(0) / 3)])]).'split'
          \ | exe 'normal! gg'
          \ | if has('vim_starting') | exe 'autocmd VimEnter * nested 2wincmd w' | endif
          \ | exe 'augroup vimrc_gitcommit | exe "au!" | augroup END'
          \ | map <buffer> Q :qall<CR>
  augroup END
endif
