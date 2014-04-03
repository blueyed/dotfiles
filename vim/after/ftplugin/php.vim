" -- adopted from indent/php.vim:
" Needs to override the default html.vim.
" Set the comment setting to something correct for PHP
setlocal comments=s1:/*,mb:*,ex:*/,://,:#

" TODO: move to snippets
inoremap <Leader>pd pre_dump();hi
inoremap <Leader>pdd pre_dump(); die();8hi
inoremap <Leader>edb echo debug_get_backtrace(); die();

" via eclim
if exists(":PhpSearchContext")
	nnoremap <silent> <buffer> <cr> :PhpSearchContext<cr>
endif

" php-funclist.txt generated using:
" curl http://www.php.net/manual/en/indexes.functions.php | sed '/class="index"/!d' | grep -oP '>[^<]+</a> - .*</li>' | cut -b2- | sed 's~</a> - ~ ; ~; s~</li>$~~' > php-funclist.txt
" curl http://www.php.net/manual/en/indexes.functions.php | sed '/class="index"/!d' | grep -oP '>[^<]+</a>'|cut -b2- | sed 's~</a>~~' > php-funclist.txt
augroup WezsPHPStuff
au BufEnter *.php set dictionary-=~/.vim/php-funclist.txt dictionary+=~/.vim/php-funclist.txt
au BufLeave *.php set dictionary-=~/.vim/php-funclist.txt
"au BufEnter *.inc set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
"au BufLeave *.inc set complete-=k~/.vim/php-funclist.txt
augroup END


" originally from http://vim.wikia.com/wiki/PHP_online_help
function! OpenPhpFunction (keyword)
  let keyword = expand(a:keyword) " expand e.g. '<cword>'
  let proc_keyword = substitute(keyword , '_', '-', 'g')
  try
    exe 'pedit __php-help__'
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
  setlocal buftype=nofile noswapfile
  call SetupPhpHelp() " allow for recursive use of 'K'

  exe 'silent r!lynx -dump -nolist http://php.net/'.proc_keyword

  " go to beginning
  norm gg
  " delete until above the line starting with the keyword
  try
    exe 'silent 1,/^' . escape(keyword, '/~.') . '/-1d'
  catch /^Vim\%((\a\+)\)\=:E486/	" catch error E486 'pattern not found'
  endtry
endfunction
command! -nargs=1 PhpLookup call OpenPhpFunction("<args>")

function! SetupPhpHelp()
  " TODO: use pman with none/flaky internet connection
  if has('unix') && ! has('gui_running') && executable('pman')
    " Use pman for help, installed via 'pear install doc.php.net/pman'
    " see http://bjori.blogspot.com/2010/01/unix-manual-pages-for-php-functions.html
    " Not for "gui_running", which has a dumb terminal only.
    setlocal keywordprg=pman
  else
    map <buffer> K :PhpLookup <cword><cr>
  endif
endfunction
call SetupPhpHelp()

" EXPERIMENTAL
setlocal iskeyword+=$

