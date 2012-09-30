" Setting filetypes with high prio, see |new-filetype|
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.ts             setfiletype typoscript
  au! BufRead,BufNewFile */doc{,s}/*.md   setfiletype markdown
augroup END

