" Save current buffer and diff the file using Tortoise SVN
map <silent> <Leader>td :w<CR>:silent !'TortoiseProc.exe' /command:diff /path:"%:p" /notempfile /closeonend<CR>

" Save current buffer and launch Tortoise SVN's revision graph
map <silent> <Leader>tr :w<CR>:silent!'TortoiseProc.exe' /command:revisiongraph epath:"%:p" /notempfile /closeonend<CR>

" Save the current buffer and execute the Tortoise SVN interface's blame program
map <Leader>tb :call TortoiseBlame()<CR>

" Save the current buffer and execute the Tortoise SVN interface's log
map <silent> <Leader>tl :w<CR>:silent !'TortoiseProc.exe' /command:log /path:"%:p" /notempfile /closeonend<CR>

function! TortoiseBlame()
  " Save the buffer
  silent execute(':w')
  " Now run Tortoise to get the blame dialog to display
  let filename = expand("%:p")
  let linenum = line(".")
  execute('!TortoiseProc.exe /command:blame /path:' . filename . ' /line:' . linenum . ' /notempfile /closeonend')
endfunction

" Save current buffer and commit the file using Tortoise SVN
map <silent> <Leader>tc :w<CR>:silent !TortoiseProc.exe /command:commit /path:"%:p" /logmsg:"%:t: " /notempfile /closeonend<CR>

" update

