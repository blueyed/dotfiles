
" Vim syntax file
" Language:         Pentadactyl configuration file
" Maintainer:       Doug Kearns <dougkearns@gmail.com>

" TODO: make this pentadactyl specific - shared dactyl config?

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn include @javascriptTop syntax/javascript.vim
unlet b:current_syntax

syn include @cssTop syntax/css.vim
unlet b:current_syntax

syn match pentadactylCommandStart "\%(^\s*:\=\)\@<=" nextgroup=pentadactylCommand,pentadactylAutoCmd

syn keyword pentadactylCommand loadplugins lpl group gr ! run Ilistkeys Ilistk
    \ Ilk Imap Im Inoremap Ino Iunmap Iunm abbreviate ab addons addo ao autocmd
    \ au back ba bdelete bd bwipeout bw bunload bun tabclose tabc bmark bma
    \ bmarks buffer b buffers files ls tabs cabbreviate ca cd chdir chd
    \ clistkeys clistk clk cmap cm cnoremap cno colorscheme colo command com
    \ completions comp contexts cookies ck cunabbreviate cuna cunmap cunm
    \ delbmarks delbm delcommand delc delgroup delg delmacros delmac delmarks
    \ delm delqmarks delqm delstyle dels dialog dia doautoall doautoa doautocmd
    \ do downloads downl dl echo ec echoerr echoe echomsg echom else el elseif
    \ elsei elif emenu em endif en fi execute exe extadd exta extdelete extde
    \ extdisable extd extenable exte extoptions exto extpreferences extp
    \ extrehash extr exttoggle extt extupdate extu feedkeys fk finish fini
    \ forward fo fw frameonly frameo gg hardcopy ha help h helpall helpa
    \ highlight hi history hist hs iabbreviate ia if ilistkeys ilistk ilk imap
    \ im inlineimages inoremap ino iunabbreviate iuna iunmap iunm javascript
    \ javas js jumps ju keepalt keepa let listcommands listc lc listkeys listk
    \ lk listoptions listo lo macros map mark ma marks messages mes messclear
    \ messc mkpentadactylrc mkp mksyntax mks mlistkeys mlistk mlk mmap mm
    \ mnoremap mno munmap munm nlistkeys nlistk nlk nmap nm nnoremap nno
    \ nohlfind noh noremap no normal norm nunmap nunm open o pageinfo pa
    \ pagestyle pagest pas preferences pref prefs pwd pw qmark qma qmarks quit q
    \ quitall quita qall qa redraw redr rehash reh reload re reloadall reloada
    \ restart res runtime runt sanitize sa saveas sav write w sbclose sbcl
    \ scriptnames scrip set se setglobal setg setlocal setl sidebar sideb sbar
    \ sb sbopen sbop silent sil source so stop st stopall stopa style sty
    \ styledisable styled stydisable styd styleenable stylee styenable stye
    \ styletoggle stylet stytoggle styt tab tabattach taba tabdetach tabde tabdo
    \ tabd bufdo bufd tabduplicate tabdu tablast tabl blast bl tabmove tabm
    \ tabnext tabn tnext tn bnext bn tabonly tabo tabopen topen t tabnew
    \ tabprevious tabp tprevious tp tabNext tabN tNext tN bprevious bp bNext bN
    \ tabrewind tabr tabfirst tabfir brewind br bfirst bf time tlistkeys tlistk
    \ tlk tmap tm tnoremap tno toolbarhide toolbarh tbhide tbh toolbarshow
    \ toolbars tbshow tbs toolbartoggle toolbart tbtoggle tbt tunmap tunm
    \ unabbreviate una undo u undoall undoa unlet unl unmap unm verbose verb
    \ version ve viewsource vie vlistkeys vlistk vlk vmap vm vnoremap vno vunmap
    \ vunm winclose winc wclose wc window wind winonly winon winopen wino wopen
    \ wo wqall wqa wq xall xa yank y zoom zo
    \ contained

syn match pentadactylCommand "!" contained

syn keyword pentadactylAutoCmd au[tocmd] contained nextgroup=pentadactylAutoEventList skipwhite

syn keyword pentadactylAutoEvent BookmarkAdd BookmarkChange BookmarkRemove
    \ ColorScheme DOMLoad DownloadPost Fullscreen LocationChange PageLoadPre
    \ PageLoad PrivateMode Sanitize ShellCmdPost Enter LeavePre Leave
    \ contained

syn match pentadactylAutoEventList "\(\a\+,\)*\a\+" contained contains=pentadactylAutoEvent

syn region pentadactylSet matchgroup=pentadactylCommand start="\%(^\s*:\=\)\@<=\<\%(setl\%[ocal]\|setg\%[lobal]\|set\=\)\=\>"
    \ end="$" keepend oneline contains=pentadactylOption,pentadactylString

syn keyword pentadactylOption activate act altwildmode awim autocomplete au
    \ cdpath cd complete cpt cookieaccept ca cookielifetime cl cookies ck
    \ defsearch ds editor encoding enc eventignore ei extendedhinttags eht
    \ fileencoding fenc findcase fc followhints fh guioptions go helpfile hf
    \ hintinputs hin hintkeys hk hintmatching hm hinttags ht hinttimeout hto
    \ history hi iskeyword isk loadplugins lpl mapleader ml maxitems messages
    \ msgs newtab nextpattern pageinfo pa passkeys pk popups pps previouspattern
    \ runtimepath rtp sanitizeitems si sanitizeshutdown ss sanitizetimespan sts
    \ scroll scr shell sh shellcmdflag shcf showstatuslinks ssli showtabline
    \ stal suggestengines timeoutlen tmol titlestring urlseparator urlsep us
    \ verbose vbs wildanchor wia wildcase wic wildignore wig wildmode wim
    \ wildsort wis wordseparators wsp
    \ contained nextgroup=pentadactylSetMod

let s:toggleOptions = ["banghist", "bh", "errorbells", "eb", "exrc", "ex",
    \ "fullscreen", "fs", "hlfind", "hlf", "incfind", "if", "insertmode", "im",
    \ "jsdebugger", "jsd", "more", "online", "private", "pornmode", "showmode",
    \ "smd", "strictfocus", "sf", "timeout", "tmo", "usermode", "um",
    \ "visualbell", "vb"]
execute 'syn match pentadactylOption "\<\%(no\|inv\)\=\%(' .
    \ join(s:toggleOptions, '\|') .
    \ '\)\>!\=" contained nextgroup=pentadactylSetMod'

syn match pentadactylSetMod "\%(\<[a-z_]\+\)\@<=&" contained

syn region pentadactylJavaScript start="\%(^\s*\%(javascript\|js\)\s\+\)\@<=" end="$" contains=@javascriptTop keepend oneline
syn region pentadactylJavaScript matchgroup=pentadactylJavaScriptDelimiter
    \ start="\%(^\s*\%(javascript\|js\)\s\+\)\@<=<<\s*\z(\h\w*\)"hs=s+2 end="^\z1$" contains=@javascriptTop fold

let s:cssRegionStart = '\%(^\s*sty\%[le]!\=\s\+\%(-\%(n\|name\)\%(\s\+\|=\)\S\+\s\+\)\=[^-]\S\+\s\+\)\@<='
execute 'syn region pentadactylCss start="' . s:cssRegionStart . '" end="$" contains=@cssTop keepend oneline'
execute 'syn region pentadactylCss matchgroup=pentadactylCssDelimiter'
    \ 'start="' . s:cssRegionStart . '<<\s*\z(\h\w*\)"hs=s+2 end="^\z1$" contains=@cssTop fold'

syn match pentadactylNotation "<[0-9A-Za-z-]\+>"

syn match   pentadactylComment +".*$+ contains=pentadactylTodo,@Spell
syn keyword pentadactylTodo FIXME NOTE TODO XXX contained

syn region pentadactylString start="\z(["']\)" end="\z1" skip="\\\\\|\\\z1" oneline

syn match pentadactylLineComment +^\s*".*$+ contains=pentadactylTodo,@Spell

" NOTE: match vim.vim highlighting group names
hi def link pentadactylAutoCmd               pentadactylCommand
hi def link pentadactylAutoEvent             Type
hi def link pentadactylCommand               Statement
hi def link pentadactylComment               Comment
hi def link pentadactylJavaScriptDelimiter   Delimiter
hi def link pentadactylCssDelimiter          Delimiter
hi def link pentadactylNotation              Special
hi def link pentadactylLineComment           Comment
hi def link pentadactylOption                PreProc
hi def link pentadactylSetMod                pentadactylOption
hi def link pentadactylString                String
hi def link pentadactylTodo                  Todo

let b:current_syntax = "pentadactyl"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: tw=130 et ts=4 sw=4:
