" Setting filetypes with high prio, see |new-filetype|
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.md.txt         setfiletype markdown
  au! BufRead,BufNewFile *.nix            setfiletype nix
  au! BufRead,BufNewFile *.ts             setfiletype typoscript
  au! BufRead,BufNewFile */doc{,s}/*.md   setfiletype markdown
  au! BufRead,BufNewFile */apache/*.conf,*/apache2/*.conf   setfiletype apache
  au! BufRead,BufNewFile */xorg.conf.d/*  setfiletype xf86conf
  au! BufRead,BufNewFile TODO             setfiletype markdown
  au! BufRead,BufNewFile /etc/network/interfaces,/etc/environment setfiletype conf
  " au! BufRead,BufNewFile *.conf           setfiletype dosini
  au! BufRead,BufNewFile *.haml           setfiletype haml
  " au! BufRead,BufNewFile *.{gpg,asc,pgp}  setfiletype gpgencrypted
  au! BufRead,BufNewFile *.pac            setfiletype pac
  au! BufRead,BufNewFile {.,}tmux*.conf*  setfiletype tmux
  au! BufRead,BufNewFile *zsh/functions*  setfiletype zsh
  au! BufNewFile,BufRead *pentadactylrc*,*.penta setfiletype pentadactyl.vim
  au! BufNewFile,BufRead *vimperatorrc*,*.vimp   setfiletype vimperator.vim
  au! BufNewFile,BufRead */tmm/**/*.html  setfiletype htmldjango
  au! BufNewFile,BufRead */socialee/**/*.html  setfiletype htmldjango
  au! BufNewFile,BufRead *.t              setfiletype cram
  au! BufNewFile,BufRead *.scal              setfiletype cram

  " From ~vp/vim-scala/ftdetect/scala.vim (lazy.loaded).
  au BufRead,BufNewFile *.scala set filetype=scala
  " Install vim-sbt for additional syntax highlighting.
  au BufRead,BufNewFile *.sbt setfiletype sbt.scala

  " Copied from ftdetect/vader.vim, because it gets loaded for ft=vader only
  " (Neobundle).
  au! BufRead,BufNewFile *.vader setfiletype vader

  au BufNewFile,BufRead */systemd/*/.[^/]\\\{-\}.{automount,mount,path,service,socket,swap,target,timer}[a-z0-9]\\\{16\}	setf systemd

  au! BufRead,BufNewFile /tmp/qutebrowser-editor* setlocal spell
augroup END
