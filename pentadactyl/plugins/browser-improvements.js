/* use strict */
XML.ignoreWhitespace = false;
XML.prettyPrinting   = false;
var INFO =
<plugin name="browser-improvements" version="0.3"
        href="http://dactyl.sf.net/pentadactyl/plugins#browser-improvements-plugin"
        summary="Browser Consistency Improvements"
        xmlns={NS}>
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Pentadactyl" min-version="1.0"/>
    <p>
        This plugin provides various browser consistency improvements, including:
    </p>
    <ul>
        <li>Middle clicking on a form submit button opens the resulting page in a new tab.</li>
        <li>Pressing <k name="C-Return" link="false"/> while a textarea or select element is focused submits the form.</li>
    </ul>
</plugin>;

function clickListener(event) {
    let elem = event.originalTarget;
    if (elem instanceof HTMLAnchorElement) {
        if (/^_(?!top$)/.test(elem.getAttribute("target")))
            elem.removeAttribute("target");
        return;
    }
    if (elem instanceof HTMLInputElement && elem.type === "submit")
        if (elem.ownerDocument.defaultView.top == content)
            if (event.button == 1)
                dactyl.open(DOM(elem).formData, dactyl.NEW_TAB);
}

function keypressListener(event) {
    let elem = event.originalTarget;
    let key = DOM.Event.stringify(event);
    let submit = function submit(form) {
        if (isinstance(form.wrappedJSObject.submit, HTMLInputElement))
            buffer.followLink(form.wrappedJSObject.submit);
        else {
            if (!DOM(form).submit().canceled)
                form.submit();
        }
    }
    if (key == "<C-Return>" && elem.form && isinstance(elem, [HTMLTextAreaElement, HTMLSelectElement]))
        submit(elem.form);
}

function onUnload() {
    group.events.unlisten(null);
}
let appContent = document.getElementById("appcontent");
group.events.listen(appContent, "click", clickListener, true);
group.events.listen(appContent, "keypress", keypressListener, true);

/* vim:se sts=4 sw=4 et: */
