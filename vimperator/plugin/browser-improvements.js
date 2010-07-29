var INFO = 
<plugin name="browser-improvements" version="0.1"
        href="http://ticket.vimperator.org/131"
        summary="Browser Consistency Improvements"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Vimperator" minVersion="2.0"/>
    <p>
        This plugin provides various browser consistency improvements, including:
    </p>
    <ul>
        <li>Middle clicking on a form submit button opens the resulting page in a new tab.</li>
        <li>Pressing <k name="C-Return"/> while a textarea or select element is focused submits the form.</li>
    </ul>
</plugin>;

function isinstance(targ, src) {
    const types = {
        boolean: Boolean, string: String, function: Function, number: Number,
    }
    src = Array.concat(src);
    for (var i=0; i < src.length; i++) {
        if (targ instanceof src[i])
            return true;
        var type = types[typeof targ];
        if (type && src[i] == type)
            return true;
    }
    return false;
}

// Nuances gleaned from browser.jar/content/browser/browser.js
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
    let uri = window.makeURI(String(doc.URL), charset);
    let url = window.makeURI(form.getAttribute("action"), charset, uri).spec;

    let post = form.method.toUpperCase() == "POST";

    let elems = [encode(submit.name, submit.value)];
    for (let [,elem] in Iterator(form.elements)) {
        if (/^(?:text|hidden|textarea)$/.test(elem.type) || elem.checked && /^(?:checkbox|radio)$/.test(elem.type))
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

function clickListener(event)
{
    let elem = event.target;
    if (elem instanceof HTMLAnchorElement) {
        if (/^_/.test(elem.getAttribute("target")))
            elem.removeAttribute("target");
	return;
    }
    if (!(elem instanceof HTMLInputElement) || elem.type != "submit")
        return;
    if (elem.ownerDocument.defaultView.top != content)
        return;
    if (event.button != 1)
        return;

    liberator.open([parseForm(elem)], liberator.NEW_TAB);
}

function keypressListener(event)
{
    let elem = event.target;
    let key = events.toString(event);
    function submit(form) {
        if (isinstance(form.submit, HTMLInputElement))
            form.submit.click();
        else if (isinstance(form.submit, Function))
            form.submit();
    }
    if (key == "<C-Return>" && isinstance(elem, [HTMLTextAreaElement, HTMLSelectElement]))
        submit(elem.form);
}

let appContent = document.getElementById("appcontent");
function onUnload()
{
    appContent.removeEventListener("click", clickListener, true);
    appContent.removeEventListener("keypress", keypressListener, true);
}
appContent.addEventListener("click", clickListener, true);
appContent.addEventListener("keypress", keypressListener, true);

/* vim:se sts=4 sw=4 et: */
