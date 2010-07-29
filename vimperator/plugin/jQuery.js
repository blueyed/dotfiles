var INFO =
<plugin name="jQuery" version="1.3.1"
        href="http://ticket.vimperator.org/137"
        summary="jQuery Integration"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <author href="http://ejohn.org/">John Resig</author>
    <author>Dojo Foundation</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <license href="http://opensource.org/licenses/bsd-license.php">BSD</license>
    <project name="Vimperator" minVersion="2.0"/>
    <p>
	This plugin provides basic jQuery integration. With it enabled,
	jQuery's <em>$</em> function is available for any web page, with the
	full power of jQuery.
        It also provides <em>$w</em>, <em>$d</em>, and <em>$b</em> objects
        which refer to the wrappedJSObjects of the content <em>window</em>,
        <em>document</em>, and <em>body</em> respectively.
    </p>
</plugin>; /*'*/


function loadJQuery(win) {
    if (win.wrappedJSObject)
        win = win.wrappedJSObject;
    if (!('jQuery' in win)) {
        head = util.evaluateXPath('//head | //xhtml:head', win.document).snapshotItem(0);
        head.appendChild(util.xmlToDom(<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>, win.document));
        head.appendChild(util.xmlToDom(<script type="text/javascript">jQuery.noConflict();</script>, win.document));
    }
    return win.jQuery;
}

userContext.$ = function() {
    let jQuery = loadJQuery(content);
    if (jQuery)
        return jQuery.apply(content.wrappedJSObject, arguments);
}
userContext.$.__defineGetter__("wrappedJSObject", function() {
    return loadJQuery(content) || this;
});
userContext.$.__noSuchMethod__ = function(meth, args) {
    let jQuery = loadJQuery(content);
    return jQuery[meth].apply(jQuery, args);
}

userContext.__defineGetter__("$w", function () content.wrappedJSObject);
userContext.__defineGetter__("$d", function () content.document.wrappedJSObject);
userContext.__defineGetter__("$b", function () (content.document.body || content.document.documentElement.lastChild).wrappedJSObject);

