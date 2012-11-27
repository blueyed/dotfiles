" Setting filetypes with high prio, see |new-filetype|
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.ts             setfiletype typoscript
  au! BufRead,BufNewFile */doc{,s}/*.md   setfiletype markdown
  au! BufRead,BufNewFile */apache/*.conf,*/apache2/*.conf   setfiletype apache
  au! BufRead,BufNewFile */xorg.conf.d/*   setfiletype xf86conf
augroup END

