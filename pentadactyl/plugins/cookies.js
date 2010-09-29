var INFO = 
<plugin name="cookies" version="0.1"
        href="http://ticket.vimperator.org/136"
        summary="Site Cookie manager"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Vimperator" minVersion="2.0"/>
    <p>
        This plugin helps managing cookies and permissions for specific sites.
        Cookies may be enabled, disabled, or enabled for the current session.
        Additionally, cookies for a given domain may be listed or cleared on
        demand.
    </p>
    <item>
        <tags>:cookies :ck</tags>
        <spec>:cookies <a>host</a> <oa>action</oa></spec>
        <description>
            <p>Manage cookies for <a>host</a></p>

            <p>Available actions:</p>

            <dl>
                <dt>unset</dt>            <dd>Unset special permissions for <a>host</a></dd>
                <dt>allow</dt>            <dd>Allow cookies from <a>host</a></dd>
                <dt>deny</dt>             <dd>Deny cookies from <a>host</a></dd>
                <dt>session</dt>          <dd>Allow cookies from <a>host</a> for the current session</dd>
                <dt>list</dt>             <dd>List all cookies for <a>host</a></dd>
                <dt>clear</dt>            <dd>Clear all cookies for <a>host</a></dd>
                <dt>clear-persistent</dt> <dd>Clear all persistent cookies for <a>host</a></dd>
                <dt>clear-session</dt>    <dd>Clear all session cookies for <a>host</a></dd>
            </dl>

            <example>:map c :cookies <k name="Tab"/></example>
        </description>
    </item>
    <item>
	<tags>'cookies' 'ck'</tags>
	<spec>'cookies' 'ck'</spec>
        <type>string</type> <default>session</default>
	<description>
            <p>
                The default action for the <ex>:cookies</ex> command.
            </p>
	</description>
    </item>
</plugin>;

services.add("cookies",     "@mozilla.org/cookiemanager;1",     [Ci.nsICookieManager, Ci.nsICookieManager2, Ci.nsICookieService]);
services.add("permissions", "@mozilla.org/permissionmanager;1", Ci.nsIPermissionManager);

function endsWith(str, value)
    str.lastIndexOf(value) == str.length - value.length;

function iter(obj) {
    if (obj instanceof Ci.nsISimpleEnumerator)
        while (obj.hasMoreElements())
            yield obj.getNext();
    else
        for (let i in Iterator(obj))
                yield i;
}

var PERMS = {
    unset:   0,
    allow:   1,
    deny:    2,
    session: 8,
};
var UNPERMS = util.Array.toObject([[v, k] for ([k, v] in Iterator(PERMS))])
var COMMANDS = {
    unset:   "Unset",
    allow:   "Allowed",
    deny:    "Dened",
    session: "Allowed for the current session",
    list:    "List all cookies for domain",
    clear:   "Clear all cookies for domain",
    "clear-persistent": "Clear all persistent cookies for domain",
    "clear-session":    "Clear all session cookies for domain",
};

function set(host, perm) {
    let uri = util.createURI(host);
    services.get("permissions").remove(uri, "cookie");
    services.get("permissions").add(uri, "cookie", PERMS[perm]);
}

function get(host) {
    let uri = util.createURI(host);
    return UNPERMS[services.get("permissions").testPermission(uri, "cookie")];
}

function iterCookies(host) {
    for (let c in iter(services.get("cookies").enumerator))
        if (c.QueryInterface(Ci.nsICookie2).rawHost == host ||
            endsWith(host, c.host))
            yield c;
}

function completeHosts(context) {
    function desc(i) {
        let host = ary.slice(i).join(".");
        let session = 0, persistent = 0;
        for (let c in iterCookies(host))
            if (c.isSession)
                session++;
            else
                persistent++;
        return [host, <>{COMMANDS[get(host)]} (session: {session} persistent: {persistent})</>]
    }

    let ary = gBrowser.currentURI.host.split(".");
    context.anchored = false;
    context.compare = CompletionContext.Sort.unsorted;
    context.completions = [desc(i) for (i in util.range(ary.length - 1, 0, -1))];
}
function completePerms(context) {
    context.keys = { text: "0", description: function ([k, v]) COMMANDS[v] };
    context.completions = iter(PERMS);
}

options.add(["cookies", "ck"],
    "The default mode for newly added cookie permissions",
    "string", "session",
    {
        completer: completePerms,
        validator: Options.validateCompleter,
    });
commands.addUserCommand(["cookies", "ck"],
    "Change cookie permissions for sites.",
    function (args) {
        let [host, cmd] = args;
        let session = true;
        if (!cmd)
            cmd = options["cookies"];

        switch (cmd) {
        case "clear":
            for (let c in iterCookies(host))
                services.get("cookies").remove(c.host, c.name, c.path, false);
            break;
        case "clear-persistent":
            session = false;
        case "clear-session":
            for (let c in iterCookies(host))
                if (c.isSession == session)
                    services.get("cookies").remove(c.host, c.name, c.path, false);
            return;

        case "list":
            liberator.echo(template.tabular(
                ["Host", "Session", "Value"], ["padding-right: 1em", "padding-right: 1em"],
                ([c.host,
                  <span highlight={c.isSession ? "Enabled" : "Disabled"}>{c.isSession ? "session" : "persistent"}</span>,
                  c.value]
                  for (c in iterCookies(host)))));
            return;
        default:
            if (!(cmd in PERMS))
                return liberator.echoerr("Invalid argument");
            set(host, cmd);
        }
    }, {
        argCount: "+",
        completer: function (context, args) {
            switch (args.completeArg) {
            case 0: completeHosts(context); break;
            case 1: context.completions = COMMANDS; break;
            }
        },
    }, true);

