" Save current buffer and diff the file using Tortoise SVN
map <silent> <Leader>td :up<CR>:silent !start TortoiseProc.exe /command:diff /path:"%:p" /notempfile /closeonend<CR>

" Save current buffer and launch Tortoise SVN's revision graph
map <silent> <Leader>tr :up<CR>:silent !start TortoiseProc.exe /command:revisiongraph epath:"%:p" /notempfile /closeonend<CR>

" Save the current buffer and execute the Tortoise SVN interface's blame program
map <Leader>tb :call TortoiseBlame()<CR>

" Save the current buffer and execute the Tortoise SVN interface's log
map <silent> <Leader>tl :up<CR>:silent !start TortoiseProc.exe /command:log /path:"%:p" /notempfile /closeonend<CR>

function! TortoiseBlame()
  " Save the buffer
  silent execute(':up')
  " Now run Tortoise to get the blame dialog to display
  let filename = expand("%:p")
  let linenum = line(".")
  execute('!start TortoiseProc.exe /command:blame /path:' . filename . ' /line:' . linenum . ' /notempfile /closeonend')
endfunction

" Save current buffer and commit the file using Tortoise SVN
map <silent> <Leader>tc :up<CR>:silent !start TortoiseProc.exe /command:commit /path:"%:p" /logmsg:"%:t: " /notempfile /closeonend<CR>

" update
map <silent> <Leader>tu :up<CR>:silent !start TortoiseProc.exe /command:update /path:"%:p" /notempfile /closeonend<CR>

