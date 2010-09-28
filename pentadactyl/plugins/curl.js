var INFO = 
<plugin name="curl" version="0.1"
        href="http://ticket.vimperator.org/130"
        summary="Curl Commandline Generator"
        xmlns={NS}>
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Vimperator" minVersion="2.0"/>
    <p>
        This plugin provides a means to generate a <tt>curl(1)</tt>
	commandline from the data in a given form.
    </p>
    <item>
	<tags>;c</tags>
	<spec>;c</spec>
	<description>
            <p>
                Generates a curl commandline from the data in the selected form.
                The command includes the data from each form element, along with
                the current User-Agent string and the cookies for the current
                page.
            </p>
	</description>
    </item>
</plugin>;

function parseForm(submit)
{
    function encode(name, value) {
        if (post)
            return name + "=" + value;
        return encodeURIComponent(name) + "=" + encodeURIComponent(value);
    }

    let form = submit.form;
    let doc = form.ownerDocument;
    let charset = doc.charset;
    let uri = window.makeURI(String(doc.URL.replace(/\?.*/, "")), charset);
    let url = window.makeURI(form.getAttribute("action"), charset, uri).spec;

    let post = form.method.toUpperCase() == "POST";

    let elems = [encode(submit.name, submit.value)];
    for (let [,elem] in Iterator(form.elements)) {
        if (/^(?:text|password|hidden|textarea)$/.test(elem.type) || elem.checked && /^(?:checkbox|radio)$/.test(elem.type))
            elems.push(encode(elem.name, elem.value));
        else if (elem instanceof HTMLSelectElement) {
            for (let [,opt] in Iterator(elem.options))
                if (opt.selected)
                    elems.push(encode(elem.name, opt.value));
        }
    }
    if (post)
        return [url, elems.map(encodeURIComponent).join('&'), elems];
    return [url + "?" + elems.join('&'), null];
}

hints.addMode('C', "Generate curl command for", function(elem) {
    if (elem.form)
        var [url, data, elems] = parseForm(elem);
    else
        var url = elem.getAttribute("href");
    if (!url || /^javascript:/.test(url))
        return;

    function escape(str) '"' + str.replace(/[\\"$]/g, "\\$&") + '"';

    util.copyToClipboard(["curl"].concat(
        [].concat(
            [["--form-string", escape(datum)] for ([n, datum] in Iterator(elems || []))],
            data != null && !elems.length ? [["-d", escape("")]] : [],
            [["-H", escape("Cookie: " + elem.ownerDocument.cookie)],
	     ["-A", escape(navigator.userAgent)],
             [escape(url)]]
        ).map(function(e) e.join(" ")).join(" \\\n\t")).join(" "), true);
});

/* vim:se sts=4 sw=4 et: */
