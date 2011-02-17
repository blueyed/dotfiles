" Vim syntax file
" Language:		TYPO3 Typoscript Template
" Maintainer:		Falko Trojahn <falko@trojahn.de>
" URL:
" Latest Revision:	2006-01-24
"
" Using the following VIM variables: {{{1
" g:sh_fold_enabled             if non-zero, syntax folding is enabled
"

" set up handling for versions {{{1
if version < 60
  syntax clear
elseif exists ("b:current_syntax")
    finish
endif

" setting up matches {{{1
syn case ignore
syn keyword typoBoolean		0 1

" to be done {{{1
" /L11"TypoScript" HTML_LANG Line Comment = # Line Comment Alt = // Line Comment Alt = / Block Comment On = /*
" Block Comment Off = */ Escape Char =  File Extensions = ts
" /Delimiters = ~!@%^&*()+-=|{}[]:;"'<> , .?
" Function String = "%[^t ]++function[^t ]+^([a-zA-Z0-9_&]+*^){"
" Function String 1 = "%[^t ]++function[^t ]+^([a-zA-Z0-9_&]+*^)^p*{"
" Indent Strings = "{"
" Unindent Strings = "}"
" # C1"HTML Tags"

" setting up TYPO3 matches {{{1
syn match typoComment /#.*/
syn match typoName /[a-zA-Z]+\./
" syn keyword typoOps < > = { } () ** [ ] ^ | || ~ ` .
" not ok yet:
syn region typoString start=/"/ end=/"/ oneline
syn region typoOps matchgroup=typoString start=/{/ end=/}/ contains=ALL
syn region typoVar matchgroup=typoString start=/\[/ end=/\]/ contains=ALL
syn match typoDelimiter /<|>/

" keywords for HTML tags {{{1
" /C4"Operators and Conditions"

syn keyword typoHTMLtags <?
syn keyword typoHTMLtags <a </a> <abbr> <abbr </abbr> <above> <acronym> <acronym </acronym> <address> <address </address> <applet </applet> <array> <area </area
syn keyword typoHTMLtags <b> <b </b> <base <basefont <bdo> <bdo </bdo> <bgsound <big> <big </big> <blink> </blink> <blockquote> <blockquote </blockquote> <body <body> </body> <box> <br <br> <br/> <big <blink <button> </button>
syn keyword typoHTMLtags <caption> <caption </caption> <center> <center </center> <cite> <cite </cite> <code> <code </code> <col> <colgroup> </colgroup> <comment> </comment>
syn keyword typoHTMLtags <dd> <dd </dd> <del> <del </del> <dfn> <dfn </dfn> <dir> <dir </dir> <div> <div </div> <dl> <dl </dl> <dt> <dt </dt>
syn keyword typoHTMLtags <em> <em </em> <embed
syn keyword typoHTMLtags <fieldset> <fieldset </fieldset> <fig> <font </font> <form> <form </form> <frame <frameset </frameset>
syn keyword typoHTMLtags <h1> <h1 </h1> <h2> <h2 </h2> <h3> <h3 </h3> <h4> <h4 </h4> <h5> <h5 </h5> <h6> <h6 </h6> <head> <head </head> <hr> <hr <hr/> <html> <html </html>
syn keyword typoHTMLtags <i> <i </i> <iframe> </iframe> <ilayer> </ilayer> <img <input> <input <ins> <ins </ins> <isindex> <isindex
syn keyword typoHTMLtags <kbd> <kbd </kbd>
syn keyword typoHTMLtags <label> <label </label> <layer> <layer </layer> <legend> <legend </legend> <li> <li </li> <link <listing> </listing>
syn keyword typoHTMLtags <map </map> <marquee </marquee> <menu> <menu </menu> <meta <multicol> </multicol>
syn keyword typoHTMLtags <nextid <nobr> </nobr> <noframes> </noframes> <nolayer> </nolayer> <note> </note> <noscript> </noscript>
syn keyword typoHTMLtags <object> <object <ol> <ol </ol> <option> <option </option> <optgroup> <optgroup </optgroup>
syn keyword typoHTMLtags <p <p> </p> <param <pre> <pre </pre>
syn keyword typoHTMLtags <q> <q </q> <quote>
syn keyword typoHTMLtags <range> <root>
syn keyword typoHTMLtags <s> <s </s> <samp> <samp </samp> <script <script> </script> <select </select> <small> <small </small> <sound <spacer> <span> <span </span> <sqrt> <strike> <strike </strike> <strong> <strong </strong> <style> <style </style> <sub> <sub </sub> <sup> <sup </sup>
syn keyword typoHTMLtags <table> <table </table> <tbody> <tbody </tbody> <td <td> </td> <text> <textarea <textarea> </textarea> <tfoot> <tfoot </tfoot> <th <th> </th> <thead> <thead </thead> <title> </title> <tr <tr> </tr> <tt> </tt> <tt
syn keyword typoHTMLtags <u> <u </u> <ul> <ul </ul>
syn keyword typoHTMLtags <var> </var> <var
syn keyword typoHTMLtags <wbr>
syn keyword typoHTMLtags <xmp> </xmp>
syn keyword typoHTMLtags ?>
syn keyword typoHTMLtags // />

" keywords for HTML attributes {{{1
" /C2"HTML Attributes"
syn keyword typoHTMLattr abbr= accept-charset= accept= accesskey= action= align= alink= alt= archive= axis=
syn keyword typoHTMLattr background= behavior below bgcolor= border= bgColor=
syn keyword typoHTMLattr cellpadding= cellspacing= char= charoff= charset= checked cite= class= classid= clear= code= codebase= codetype= color= cols= colspan= content= coords=
syn keyword typoHTMLattr data= datetime= defer dir= disabled
syn keyword typoHTMLattr enctype=
syn keyword typoHTMLattr face= for= frame= frameborder= framespacing=
syn keyword typoHTMLattr headers= height= hidden= href= hreflang= hspace= http-equiv=
syn keyword typoHTMLattr id= ismap=
syn keyword typoHTMLattr label= lang= language= link= loop= longdesc= leftmargin=
syn keyword typoHTMLattr mailto= marginheight= marginwidth= maxlength= media= method= multiple
syn keyword typoHTMLattr name= nohref noresize noshade
syn keyword typoHTMLattr object= onblur= onchange= onfocus= onkeydown= onkeypress= onkeyup= onload= onreset= onselect= onsubmit= onunload= onclick= ondblclick= onmousedown= onmousemove= onmouseout= onmouseover= onmouseup= onLoad=
syn keyword typoHTMLattr OnMouseOver= OnMouseOut=
syn keyword typoHTMLattr profile= prompt=
syn keyword typoHTMLattr readonly rel= rev= rows= rowspan= rules=
syn keyword typoHTMLattr scheme= scope= scrolling= selected shape= size= span= src= standby= start= style= summary=
syn keyword typoHTMLattr tabindex= target= text= title= topmargin= type=
syn keyword typoHTMLattr url= usemap=
syn keyword typoHTMLattr valign= value= valuetype= version= vlink= vspace=
syn keyword typoHTMLattr width=

" keywords for TYPO3 keywords {{{1
" /C3"Keywords"
syn keyword typoKEY alt_print config data directory displaySingle displayLatest displayList external firstImageIsPreview
syn keyword typoKEY global image includeLibs key lib marks main plugin page pageBrowser
syn keyword typoKEY PAGE_TARGET PAGE_TITLE PAGE_AUTHOR PAGE_SUBTITLE
syn keyword typoKEY rootline special sub temp template templateFile value

" keywords for TYPO3 methods, properties and constants {{{1
" /C5"Methods, Properties and Constants"
syntax case match
syn keyword typoTAG user_ addHeight addWidth admPanel allWrap ATagParams
syn keyword typoTAG bannertop beforeImg beforeROImg bodyTag buttonText baseURL
syn keyword typoTAG case collapse code content content_from_pid_allowOutsideDomain cObject crop catTextMode catTextLength
syn keyword typoTAG defaultTemplateObjectMain defaultTemplateObjectSub disablePrefixComment displayActiveOnLoad
syn keyword typoTAG doNotLinkIt dontHideOnMouseUp date_stdWrap
syn keyword typoTAG entryLevel expAll extTarget enable expand
syn keyword typoTAG field file fontColor fontFile fontSize freezeMouseover filter firstImageIsPreview
syn keyword typoTAG gmenu_layers get headerData headerComment hideMenuWhenNotOver height htmlSpecialChars
syn keyword typoTAG imgParams index_enable index_externals intTarget inlineStyle2TempFile if isTrue inheritMainTemplates iconv ifEmpty imageCount
syn keyword typoTAG inheritSubTemplates imageWrapIfAny imageLinkWrap Image JSwindow
syn keyword typoTAG layerStyle linkWrap lockPosition lockPosition_addSelf limit language locale_all
syn keyword typoTAG maxPages meta mode maxCatTexts maxW maxH niceText noBlur newWindow offset
syn keyword typoTAG pidList placement parameter prefixLocalAnchors
syn keyword typoTAG range relativeToParentLayer relativeToTriggerItem removeDefaultJS required recursive restrict results_at_a_time
syn keyword typoTAG safeSearch shortcutIcon simulateStaticDocuments_noTypeIfNoTitle spamProtectEmailAddresses subparts showPBrowserText showResultCount
syn keyword typoTAG spamProtectEmailAddresses_atSubst stdWrap stylesheet strftime subheader_stdWrap singleMaxW singleMaxH simulateStaticDocuments sys_language_uid styles
syn keyword typoTAG target templateType templateObjects text textMaxLength tmenu_layers topOffset transparentBackground typeNum tableParams time_stdWrap typolink tx_realurl_enable
syn keyword typoTAG upper workOnSubpart wrap wrapItemAndSub width ypMenu

" /C6"Variables and filepaths" {{{1
" ** fileadmin/
" ** :
" ** $

" keywords for TYPO3 plugins {{{1
" /C7"PlugIns"
" syn keyword typoPLUG usoap
syn keyword typoPLUG tt_board tt_guest tt_news tt_content tx_macinabanners_pi1 tx_rlmptmplselector tx_rlmptmplselector_pi1 tx_googleapisearch_pi1
" syn match typoPLUG /[tt_|tx_][a-zA-Z]+/

" keywords for TYPO3 objects and markers {{{1
" /C8"Objects and Markers"
syntax case match
syn keyword typoMARK CR_ obj ACTIFSUB ACT css CASE CUR COA CONTENT CSS DB FILE gif
syn keyword typoMARK GMENU GMENU_LAYERS GIF
syn keyword typoMARK htm html HMENU HTML HTM IFSUB IMAGE JPG jpg NO PAGE PNG png RO tmpl
syn keyword typoMARK TEMPLATE TEXT TMENU TMENU_LAYERS TMPL XY

" Default Highlighting: {{{1
" =====================
hi def link shArithmetic                        Special
hi def link shCharClass                         Identifier
hi def link shFunctionName                      Function
hi def link shNumber                            Number
hi def link shRepeat                            Repeat
hi def link typoOps                             Identifier
hi def link typoTAG                             Comment
hi def link typoName                            Conditional
hi def link typoString                          Delimiter
hi def link typoDelimite                        Delimiter
hi def link typoBoolean                         Operator
hi def link typoComment                         PreProc
hi def link typoHTMLattr                        Special
hi def link typoHTMLtags                        Special
hi def link typoKEY                             Statement
hi def link typoMARK                            String
hi def link typoPLUG                            Todo


" set up default g:sh_fold_enabled {{{1
if !exists("g:sh_fold_enabled")
 let g:sh_fold_enabled= 0
elseif g:sh_fold_enabled != 0 && !has("folding")
  let g:sh_fold_enabled= 0
   echomsg "Ignoring g:sh_fold_enabled=".g:sh_fold_enabled."; need to
   re-compile vim for +fold support"
endif
if g:sh_fold_enabled && &fdm == "manual"
    set fdm=syntax
endif



let b:current_syntax = "typoscript"
