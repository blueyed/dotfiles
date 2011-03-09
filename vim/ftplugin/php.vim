" Use pman for help, installed via 'pear install doc.php.net/pman'
" see http://bjori.blogspot.com/2010/01/unix-manual-pages-for-php-functions.html
setlocal keywordprg=pman


" TODO: move to snippets
inoremap <Leader>pd pre_dump();hi
inoremap <Leader>pdd pre_dump(); die();8hi
inoremap <Leader>edb echo debug_get_backtrace(); die();


" php-funclist.txt generated using:
" curl http://www.php.net/manual/en/indexes.php | sed '/class="indexentry"/!d' | grep -oP '>[^<]+</a>'|cut -b2- | sed 's~()</a>~~' > php-funclist.txt
augroup WezsPHPStuff
au BufEnter *.php set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
au BufLeave *.php set complete-=k~/.vim/php-funclist.txt
"au BufEnter *.inc set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
"au BufLeave *.inc set complete-=k~/.vim/php-funclist.txt
augroup END



function! OpenPhpFunction (keyword)
  let proc_keyword = substitute(a:keyword , '_', '-', 'g')
  " create new preview split or switch to existing.
  "   vim has a Preview split which is a singleton,
  "   one per tab. This is perfect for repeated
  "   uses of the manual feature.
  " for some reason, I was getting errors
  " when trying to open a preview window.
  " but I'm unable to reproduce. Who knows...
  " try opening a new preview window.
  try
    exe 'pedit'
    " sometimes seems to throw an error
  catch /.*/
  endtry
  " switch to the preview
  exe 'wincmd P'
  " edit a new buffer
  exe 'enew'

  " don't associate any file or swap file
  " with this buffer. http://vim.wikia.com/wiki/VimTip135
  " the first command automatically names
  " the buffer [Scratch]. We could use this
  " to reuse the scratch window.
  exe "set buftype=nofile"
  exe "setlocal noswapfile"

  "call browser and fetch the file. we use lynx here.
  "php actually has a great script that fetches
  "info on lots of things other than functions.
  "so let it do its thing.
  exe 'silent r!lynx -dump -nolist http://php.net/'.proc_keyword

  " now we format the results:
  " enter normal mode and go to top of manual entry
  exe 'norm gg'
  " 1. this was given by original author
  "    at http://vim.wikia.com/wiki/PHP_online_help
  "    Problem: doesn't search far enough down the page
  "    exe 'call search ("' . a:keyword .'")'
  " 2. I came up with this to remove stuff at top of
  "    file for function retrievals.
  "    Idea: search down to Description. Then go up 8 lines.
  "    Problem: doesn't work for non-function man pages.
  "    exe 'call search("Description")'
  "    exe 'norm 8kdgg'
  " 3. Best idea so far: search down to a really long underscore.
  "    This will be the search box if your underscore is short.
  "    If it's long enough, you'll match on the horizontal line
  "    that is above the definition we really want.
  exe 'call search("____________________________________")'
  exe 'norm dgg'
  " delete the user notes at the bottom. it's a lot of text,
  " and they are almost completely useless.
  exe 'call search("User Contributed Notes")'
  exe 'norm dGgg'
endfunction

" manual lookup is mapped to ctrl-p
" ctrl-o is used to jump out of insert mode for one command.
" - jump out for one command <C-O>
" - call OpenPhpFunction with the word under cursor
" - CR seems to indicate end of fcn call
" - <C-O> again - we are in insert mode in the man page
" - this time, we jump back to previous window.
" - at the end of the day, we are still in insert mode,
"   the cursor is in exactly the same spot, and the man
"   page for php is visible
" TODO
"inoremap <C-p> <C-O>:call OpenPhpFunction('<c-r><c-w>')<CR><C-O>:wincmd p<CR>
"nnoremap <C-p> :call OpenPhpFunction('<c-r><c-w>')<CR>:wincmd p<CR>
"vnoremap <C-p> :call OpenPhpFunction('<c-r><c-w>')<CR>:wincmd p<CR>
