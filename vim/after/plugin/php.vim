" php-funclist.txt generated using:
" curl http://www.php.net/manual/en/indexes.php | sed '/class="indexentry"/!d' | grep -oP '>[^<]+</a>'|cut -b2- | sed 's~()</a>~~' > php-funclist.txt
augroup WezsPHPStuff
au BufEnter *.php set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
au BufLeave *.php set complete-=k~/.vim/php-funclist.txt
"au BufEnter *.inc set complete-=k~/.vim/php-funclist.txt complete+=k~/.vim/php-funclist.txt
"au BufLeave *.inc set complete-=k~/.vim/php-funclist.txt
augroup END

