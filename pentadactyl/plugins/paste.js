/**
 **
 ** paste.js
 ** 
 ** description :
 **  pastebin is a script to paste clipboard's content
 **  in a new pastebin. Its URL is yanked.
 **
 **
 **
 * @author Yoann Lamouroux (spamonsophia@gmail.com) (legreffier@freenode)
 * @version 1.0 now exhaustive.
 *
 **/
var INFO =
<plugin name="paste" version="1.0"
		href="http://www.overthewire.org/"
		summary="Pastebin wrapper"
		xmlns="http://vimperator.org/namespaces/liberator">
	<author email="spamonsophia@gmail.com">Yoann Lamouroux</author>
	<license href="http://www.opensource.org/licenses/mit-license.html">MIT</license>
	<project name="Vimperator" minVersion="2.0" />
	<p>
		This plugin allow you to fill pastebins with clipboard's content.
	</p>
	<item>
		<tags>:past :pastebin</tags>
		<spec>:past[ebin] <oa>-name=author</oa> <oa>-language=language</oa> <oa>-private</oa> <oa>-mail=you@lolcat.org</oa> <oa>-subdomain=subdom</oa></spec>
		<description>
			<p>Paste the clipboard's content in a new pastebin, yanks its URL.</p>
			<p>You can use several options : </p>
			<ul>
				<li>-name your_name (or -n) : to give your pastes an author</li>
				<li>-language syntax_hilight (or -l) : to enable syntax hilighting</li>
				<li>-private (or -p) : to make your pastebin private (sort of)</li>
				<li>-mail login@mail.tld (or -m) : add a mail address</li>
				<li>-subdomain subdom (or -s) : send the buffer to subdom.pastebin.com</li>
			</ul>
		</description>
	</item>
</plugin>;

function pasteBin(arg) {
	var url = "http://pastebin.com/api_public.php";
	var http = new XMLHttpRequest();
	var params = arg + "paste_code=";
	var paste = util.readFromClipboard();
	if(!paste) {
		liberator.echoerr("The clipboard is empty.\n"); 
		return;
	} else {
		params += paste;
	}
	http.open("POST", url, true);

	//Send the proper header information along with the request
	http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	http.setRequestHeader("Content-length", params.length);
	http.setRequestHeader("Connection", "close");

	http.send(params);
	http.onreadystatechange = function() {
		if(http.readyState == 4 && http.status == 200) {
			util.copyToClipboard(http.responseText);
			liberator.echo("Yanked " + http.responseText);
		} 		
	}
}

var expilist = [['N', 'Never'], ['10M', 'Ten minutes'], ['1H', 'One hour'], ['1D', 'One day'], ['1M', 'One month']];

var langlist = [    // looooooongcat, he's rather long.
	['abap', 'ABAP'], 
	['actionscript', 'ActionScript'], 
	['actionscript3', 'ActionScript3'], 
	['ada', 'Ada'],
	['apache', 'Apache'], 
	['applescript', 'AppleScript'], 
	['apt_sources', 'APT Sources'], 
	['asm', 'Assembler'], 
	['asp', 'ASP'], 
	['autoit', 'AutoIt'], 
	['avisynth', 'Avisynth'], 
	['bash', 'Bash script'], 
	['basic4gl', 'Basic4GL'], 
	['bibtex', 'BibTeXgi'], 
	['blitzbasic', 'Blitz Basic'], 
	['bnf', 'BNF'], 
	['boo', 'Boo'], 
	['bf', 'BrainFuck'], 
	['c', 'C'], 
	['c_mac', 'C for Macs'], 
	['cill', 'C Intermediate Language'], 
	['csharp', 'C#'], 
	['cpp', 'C++'], 
	['caddcl', 'CAD DCL'], 
	['cadlisp', 'CAD Lisp'], 
	['cfdg', 'CFDG'], 
	['klonec', 'Clone C'], 
	['klonecpp', 'Clone C++'], 
	['cmake', 'CMake'], 
	['cobol', 'Cobol'], 
	['cfm', 'ColdFusion'], 
	['css', 'CSS'], 
	['d', 'D'], 
	['dcs', 'DCS'], 
	['delphi', 'Delphi'], 
	['dff', 'Diff'], 
	['div', 'DIV'], 
	['dos', 'DOS'], 
	['dot', 'DOT'], 
	['eiffel', 'Eiffel'], 
	['email', 'E-mail'], 
	['erlang', 'Erlang'], 
	['fo', 'FO Language'], 
	['fortran', 'Fortran'], 
	['freebasic', 'FreeBasic'], 
	['gml', 'Game Maker'], 
	['genero', 'Genero'], 
	['gettext', 'GetText'], 
	['groovy', 'Groovy'], 
	['haskell', 'Haskell'], 
	['hq9plus', 'HQ9 Plus'], 
	['html4strict', 'HTML4 strict'], 
	['idl', 'IDL'], 
	['ini', 'INI configuration file'], 
	['inno', 'Inno script'], 
	['intercal', 'INTERCAL'], 
	['io', 'IO'], 
	['java', 'Java'], 
	['java5', 'Java5'], 
	['javascript', 'JavaScript'], 
	['kixtart', 'KiXtart'], 
	['latex', 'Latex'], 
	['lsl2', 'Linden Scripting'], 
	['lisp', 'Lisp'], 
	['locobasic', 'Loco Basic'], 
	['lolcode', 'LOL Code'], 
	['lotusformulas', 'Lotus Formulas'], 
	['lotusscript', 'Lotus Script'], 
	['lscript', 'LScript'], 
	['lua', 'Lua'], 
	['m68k', 'M68000 Assembler'], 
	['make', 'Makefile'],  
	['matlab', 'MatLab'], 
	['matlab', 'MatLab'], 
	['mirc', 'mIRC'], 
	['modula3', 'Modula 3'], 
	['mpasm', 'MPASM'], 
	['mxml', 'MXML'], 
	['mysql', 'MySQL'], 
	['nsis', 'NullSoft Installer'], 
	['oberon2', 'Oberon 2'], 
	['objc', 'Objective C'], 
	['ocaml-brief', 'OCaml Brief'], 
	['ocaml', 'OCaml'], 
	['glsl', 'OpenGL Shading'], 
	['oobas', 'OpenOffice Basic'], 
	['oracle11', 'Oracle 11'], 
	['oracle8', 'Oracle 8'], 
	['pascal', 'Pascal'], 
	['pawn', 'PAWN'], 
	['per', 'Per'], 
	['perl', 'Perl'], 
	['php', 'PHP'], 
	['php-brief', 'PHP Brief'], 
	['pic16', 'Pic 16'], 
	['pixelbender', 'Pixel Bender'], 
	['plsql', 'PL/SQL'], 
	['povray', 'POV-Ray'], 
	['powershell', 'PowerShell'], 
	['progress', 'Progress'], 
	['prolog', 'Prolog'], 
	['properties', 'Properties'], 
	['providex', 'ProvideX'], 
	['python', 'Python'], 
	['qbasic', 'Quick Basic'], 
	['rails', 'Rails'], 
	['rebol', 'REBOL'], 
	['reg', 'REG'], 
	['robots', 'Robots'], 
	['ruby', 'Ruby'], 
	['gnuplot', 'Ruby Gnuplot'], 
	['sas', 'SAS'], 
	['scala', 'Scala'], 
	['scheme', 'Scheme'], 
	['scilab', 'Scilab'], 
	['sdlbasic', 'SDL Basic'], 
	['smalltalk', 'SmallTalk'], 
	['smarty', 'Smarty'], 
	['sql', 'SQL'], 
	['tsql', 'T-SQL'], 
	['tcl', 'TCL'], 
	['tcl', 'tcl'], 
	['teraterm', 'Tera Term'], 
	['thinbasic', 'thinBasic'], 
	['typoscript', 'TypoScript'], 
	['unreal', 'unrealScript'], 
	['vbnet', 'VB.NET'], 
	['verilog', 'VeriLog'], 
	['vhdl', 'VHDL'], 
	['vim', 'Vim'], 
	['visualprolog', 'Visual Pro Log'], 
	['vb', 'Visual Basic'], 
	['visualfoxpro', 'VisualFoxPro'], 
	['whitespace', 'WhiteSpace'], 
	['whois', 'WHOIS'], 
	['winbatch', 'Win Batch'], 
	['xml', 'XML'], 
	['xorg_conf', 'xorg.conf'], 
	['xpp', 'XPP'], 
	['z80', 'z80 Assembler']];

commands.addUserCommand(
	"past[ebin]", 
	"pastebin the clipboard, store the address in clipboard",
	function(args) { 
		var prefix = "";
		if(args["-name"]) {
			prefix += "paste_name=" + args["-name"] + "&";
		}
		if(args["-language"]) {
			var ok = 0;
			for each (l in langlist) {
				if(args["-language"] === l[0]) {
					prefix += "paste_format=" + args["-language"] + "&";
					ok++;
					break;
				}
			}
			if(ok == 0) liberator.echo("language argument not recognized, defaulting to none");
		}
		if(args["-expire"]) {
			var ok = 0;
			for each (l in expilist) {
				if(args["-expire"] === l[0]) {
					prefix += "paste_expire_date=" + args["-expire"] + "&";
					ok++;
					break;
				}
			}
			if(ok == 0) { 
				liberator.echo("expire argument not recognized, defaulting to minutes");
				prefix += "paste_expire_date=10M&";
			}
		}
		if(args["-mail"]) {
			prefix += "paste_email=" + args["-mail"] + "&";
		}
		if(args["-subdomain"]) {
			prefix += "paste_subdomain=" + args["-subdomain"] + "&";
		}
		if(args["-private"]) {
			prefix += "paste_private=1&"
		}
		pasteBin(prefix); 
	}, {
		options: [ 
			[["-name", "-n"], commands.OPTION_STRING, function(arg) /\w+/.test(arg)],
			[["-language", "-l"], commands.OPTION_STRING, null, langlist],
			[["-expire", "-e"], commands.OPTION_STRING , null, expilist],
			[["-mail", "-m"], commands.OPTION_STRING, function(arg) /^.+\@.+\.\w+$/.test(arg)],
			[["-subdomain", "-s"], commands.OPTION_STRING, function(arg) /\w+/.test(arg)],
			[["-private", "-p"], commands.OPTION_NOARG]
		] }
);
