" TODO: move to snippets
inoremap <Leader>pd pre_dump();hi
inoremap <Leader>pdd pre_dump(); die();8hi
inoremap <Leader>edb echo debug_get_backtrace(); die();

" via eclim
if exists(":PhpSearchContext")
	nnoremap <silent> <buffer> <cr> :PhpSearchContext<cr>
endif

" php-funclist.txt generated using:
" curl http://www.php.net/manual/en/indexes.php | sed '/class="indexentry"/!d' | grep -oP '>[^<]+</a>'|cut -b2- | sed 's~()</a>~~' > php-funclist.txt
augroup WezsPHPStuff
au BufEnter *.php set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
au BufLeave *.php set complete-=k~/.vim/php-funclist.txt
"au BufEnter *.inc set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
"au BufLeave *.inc set complete-=k~/.vim/php-funclist.txt
augroup END


" originally from http://vim.wikia.com/wiki/PHP_online_help
function! OpenPhpFunction (keyword)
  let proc_keyword = substitute(a:keyword , '_', '-', 'g')
  try
    exe 'pedit'
    " sometimes seems to throw an error
  catch /.*/
  endtry
  " switch to the preview
  wincmd P
  " edit a new buffer
  enew

  " don't associate any file or swap file
  " with this buffer. http://vim.wikia.com/wiki/VimTip135
  " the first command automatically names
  " the buffer [Scratch]. We could use this
  " to reuse the scratch window.
  set buftype=nofile
  setlocal noswapfile

  exe 'silent r!lynx -dump -nolist http://php.net/'.proc_keyword

  " go to beginning
  norm gg
  " delete until above the line starting with the keyword
  exe 'silent 1,/^' . a:keyword . '/-1d'
endfunction
command! -nargs=1 PhpLookup call OpenPhpFunction("<args>")

if has('unix') && executable('pman')
  " Use pman for help, installed via 'pear install doc.php.net/pman'
  " see http://bjori.blogspot.com/2010/01/unix-manual-pages-for-php-functions.html
  setlocal keywordprg=pman
else
  " does not appear to work with 7.3.35 - newer feature?!
  setlocal keywordprg=:PhpLookup
endif


