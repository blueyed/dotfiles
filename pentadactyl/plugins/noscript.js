/*
 * Copyright ©2010 Kris Maglione <maglione.k at Gmail>
 * Distributable under the terms of the MIT license.
 *
 * Documentation is at the tail of this file.
 */
"use strict";

dactyl.assert("noscriptOverlay" in window,
              "This plugin requires the NoScript add-on.");

function subdomains(host) {
    if (/(^|\.)\d+$|:.*:/.test(host))
        // IP address or similar
        return [host];

    let tld = host.replace(/.*\./, "");
    try {
        tld = services.get("tld").getBaseDomainFromHost(host);
    }
    catch (e) {}

    let ary = host.split(".");
    ary = [ary.slice(i).join(".") for (i in util.range(ary.length - 1, 0, -1))];
    return ary.filter(function (h) h.length >= tld.length);
}

/*
 *  this.globalJS ? !this.alwaysBlockUntrustedContent || !this.untrustedSites.matches(s)
 *                : this.jsPolicySites.matches(s) && !this.untrustedSites.matches(s) && !this.isForbiddenByHttpsStatus(s));
 */

function getSites() {
    // This logic comes directly from NoScript. To my mind, it's insane.
    const ns     = services.get("noscript");
    const global = options["script"];
    const groups = { allowed: ns.jsPolicySites, temp: ns.tempSites, untrusted: ns.untrustedSites };
    const show   = set(options["noscript-list"]);
    const sites  = window.noscriptOverlay.getSites();

    const blockUntrusted = global && ns.alwaysBlockUntrustedContent;

    let res = [];
    for (let site in array.iterValues(Array.concat(sites.topSite, sites))) {
        let ary = [];

        let untrusted    = groups.untrusted.matches(site);
        let matchingSite = null;
        if (!untrusted)
            matchingSite = groups.allowed.matches(site) || blockUntrusted && site;

        let enabled = Boolean(matchingSite);
        if (site == sites.topSite && !ns.dom.getDocShellForWindow(content).allowJavascript)
            enabled = false;

        let hasPort = /:\d+$/.test(site);

        if (enabled && !global || untrusted) {
            if (!enabled || global)
                matchingSite = untrusted;

            if (hasPort && ns.ignorePorts)
                if (site = groups.allowed.matches(site.replace(/:\d+$/, "")))
                    matchingSite = site;
            ary.push(matchingSite);
        }
        else {
            if ((!hasPort || ns.ignorePorts) && (show.full || show.base)) {
                let domain = !ns.isForbiddenByHttpsStatus(site) && ns.getDomain(site);
                if (domain && ns.isJSEnabled(domain) == enabled) {
                    ary = subdomains(domain);
                    if (!show.base && ary.length > 1)
                        ary = ary.slice(1);
                    if (!show.full)
                        ary = ary.slice(0, 1);
                }
            }

            if (show.address || ary.length == 0) {
                ary.push(site);

                if (hasPort && ns.ignorePorts) {
                    site = site.replace(/:\d+$/, "");
                    if (!groups.allowed.matches(site))
                        ary.push(site);
                }
            }
        }
        res = res.concat(ary);
    }

    let seen = {};
    return res.filter(function (h) !set.add(seen, h));
}
function getObjects() {
    let sites = noscriptOverlay.getSites();
    let general = [], specific = [];
    for (let group in values(sites.pluginExtras))
        for (let obj in array.iterValues(group)) {
            if (!obj.placeholder && (ns.isAllowedObject(obj.url, obj.mime) || obj.tag))
                continue;
            specific.push(obj.mime + "@" + obj.url);
            general.push("*@" + obj.url);
            general.push("*@" + obj.site);
        }
    let sites = buffer.allFrames().map(function (f) f.location.host);
    for (let filter in values(options["noscript-objects"])) {
        let host = util.getHost(util.split(filter, /@/, 2)[1]);
        if (sites.some(function (s) s == host))
            specific.push(filter);
    }
    let seen = {};
    return specific.concat(general).filter(function (site) !set.add(seen, site));
}

highlight.loadCSS(<css>
    NoScriptAllowed         color: green;
    NoScriptBlocked         color: #444; font-style: italic;
    NoScriptTemp            color: blue;
    NoScriptUntrusted       color: #c00; font-style: italic;
</css>);

let groupProto = {};
["temp", "jsPolicy", "untrusted"].forEach(function (group)
    memoize(groupProto, group, function () services.get("noscript")[group + "Sites"].matches(this.site)));
let groupDesc = {
    NoScriptTemp:       "Temporarily allowed",
    NoScriptAllowed:    "Allowed permanantly",
    NoScriptUntrusted:  "Untrusted",
    NoScriptBlocked:    "Blocked"
};

function splitContext(context, generate, list) {
    for (let [name, title, filter] in values(list)) {
        let ctxt = context.fork(name);
        ctxt.title = [title];
        ctxt.generate = generate;
        ctxt.filters.push(filter);
    }
}

completion.noscriptObjects = function (context) {
    const ns = services.get("noscript");
    let whitelist = this.set;
    context = context.fork();
    context.compare = CompletionContext.Sort.unsorted;
    context.keys = {
        text: util.identity,
        description: function (key) set.has(whitelist, key) ? "Allowed" : "Forbidden"
    };
    splitContext(context, getObjects, [
        ["forbidden", "Forbidden objects", function (item) !set.has(whitelist, item.item)],
        ["allowed",   "Allowed objects",   function (item) set.has(whitelist, item.item)]]);
};
completion.noscriptSites = function (context) {
    const ns = services.get("noscript");

    context.pushProcessor(0, function (item, text, next)
        next.call(this, item, <span highlight={item.group}>{text}</span>));
    context.compare = CompletionContext.Sort.unsorted;
    context.keys = {
        text: util.identity,
        description: function (site) groupDesc[this.group] +
            (this.groups.untrusted && this.group != "NoScriptUntrusted" ? " (untrusted)" : ""),

        group: function (site) this.groups.temp      ? "NoScriptTemp" :
                               this.groups.jsPolicy  ? "NoScriptAllowed" :
                               this.groups.untrusted ? "NoScriptUntrusted" :
                                                       "NoScriptBlocked",
        groups: function (site) ({ site: site, __proto__: groupProto })
    };
    splitContext(context, getSites, [
        ["normal",    "Active sites",    function (item) item.groups.jsPolicy || !item.groups.untrusted],
        ["untrusted", "Untrusted sites", function (item) !item.groups.jsPolicy && item.groups.untrusted]]);
    context.maxItems = 100;
}

services.add("noscript", "@maone.net/noscript-service;1");

var PrefBase = "noscript.";
var Pref = Struct("text", "pref", "description");
let prefs = {
    forbid: [
        ["bookmarklet", "forbidBookmarklets", "Forbid bookmarklets"],
        ["collapse",    "collapseObject",     "Collapse forbidden objects"],
        ["flash",       "forbidFlash",        "Block Adobe® Flash® animations"],
        ["fonts",       "forbidFonts",        "Forbid remote font loading"],
        ["frame",       "forbidFrames",       "Block foreign <frame> elements"],
        ["iframe",      "forbidIFrames",      "Block foreign <iframe> elements"],
        ["java",        "forbidJava",         "Block Java™ applets"],
        ["media",       "forbidMedia",        "Block <audio> and <video> elements"],
        ["placeholder", "showPlaceholder",    "Replace forbidden objects with a placeholder"],
        ["plugins",     "forbidPlugins",      "Forbid other plugins"],
        ["refresh",     "forbidMetaRefresh",  "Block <meta> page directions"],
        ["silverlight", "forbidSilverlight",  "Block Microsoft® Silverlight™ objects"],
        ["trusted",     "contentBlocker",     "Block media and plugins even on trusted sites"],
        ["webbug",      "blockNSWB",          "Block “web bug” tracking images"],
        ["xslt",        "forbidXSLT",         "Forbid XSLT stylesheets"]
    ],
    list: [
        ["address", "showAddress",    "Show the full address (http://www.google.com)"],
        ["base",    "showBaseDomain", "Show the base domain (google.com)"],
        ["full",    "showDomain",     "Show the full domain (www.google.com)"]
    ]
};
for (let [k, v] in Iterator(prefs))
    prefs[k] = array(v).map(function (v) [v[0], Pref.fromArray(v.map(UTF8))]).toObject();

function getPref(pref)      modules.prefs.get(PrefBase + pref);
function setPref(pref, val) modules.prefs.get(PrefBase + pref, val);

prefs.complete = function prefsComplete(group) function (context) {
    context.keys = { text: "text", description: "description" };
    context.completions = values(prefs[group]);
}
prefs.get = function prefsGet(group) [p.text for (p in values(this[group])) if (getPref(p.pref))];
prefs.set = function prefsSet(group, val) {
    for (let p in values(this[group]))
        setPref(p.pref, val.indexOf(p.text) >= 0);
    return val;
}
prefs.descs = function prefDescs(group) <dl>
    { template.map(values(this[group]), function (pref)
        <><dt>{pref.text}</dt> <dd>{pref.description}</dd></>) }
</dl>;

function groupParams(group) ( {
    getter: function () prefs.get(group),
    completer: prefs.complete(group),
    setter: function (val) prefs.set(group, val),
    initialValue: true,
    persist: false
});
options.add(["noscript-forbid", "nsf"],
    "The set of permissions forbidden to untrusted sites",
    "stringlist", "",
    groupParams("forbid"));
options.add(["noscript-list", "nsl"],
    "The set of domains to show in the menu and completion list",
    "stringlist", "",
    groupParams("list"));

options.add(["script"],
    "Whether NoScript is enabled",
    "boolean", false,
    {
        getter: function () services.get("noscript").jsEnabled,
        setter: function (val) services.get("noscript").jsEnabled = val,
        initialValue: true,
        persist: false
    });

[
    {
        names: ["noscript-sites", "nss"],
        description: "The list of sites allowed to execute scripts",
        action: function (add, sites) sites.length && noscriptOverlay.safeAllow(sites, add, false, -1),
        completer: function (context) completion.noscriptSites(context),
        has: function (val) set.has(services.get("noscript").jsPolicySites.sitesMap, val) &&
            !set.has(services.get("noscript").tempSites.sitesMap, val),
        get set() set.subtract(
            services.get("noscript").jsPolicySites.sitesMap,
            services.get("noscript").tempSites.sitesMap)
    }, {
        names: ["noscript-tempsites", "nst"],
        description: "The list of sites temporarily allowed to execute scripts",
        action: function (add, sites) sites.length && noscriptOverlay.safeAllow(sites, add, true, -1),
        completer: function (context) completion.noscriptSites(context),
        get set() services.get("noscript").tempSites.sitesMap
    }, {
        names: ["noscript-untrusted", "nsu"],
        description: "The list of untrusted sites",
        action: function (add, sites) sites.length && services.get("noscript").setUntrusted(sites, true),
        completer: function (context) completion.noscriptSites(context),
        get set() services.get("noscript").untrustedSites.sitesMap
    }, {
        names: ["noscript-objects", "nso"],
        description: "The list of allowed objects",
        get set() set(array.flatten(
            [Array.concat(v).map(function (v) v + "@" + this, k)
             for ([k, v] in Iterator(services.get("noscript").objectWhitelist))])),
        action: function (add, patterns) {
            const ns = services.get("noscript");
            for (let pattern in values(patterns)) {
                let [mime, site] = util.split(pattern, /@/, 2);
                if (add)
                    ns.allowObject(site, mime);
                else {
                    let list = ns.objectWhitelist[site];
                    if (list) {
                        if (list == "*") {
                            delete ns.objectWhitelist[site];
                            ns.objectWhitelistLen--;
                        }
                        else {
                            let types = list.filter(function (type) type != mime);
                            ns.objectWhitelistLen -= list.length - types.length;
                            ns.objectWhitelist[site] = types;
                            if (!types.length)
                                delete ns.objectWhitelist[site];
                        }
                    }
                }
            }
            if (add)
                ns.reloadAllowedObjects(config.browser.selectedBrowser);
        },
        completer: function (context) completion.noscriptObjects(context)
    }
].forEach(function (params)
    options.add(params.names, params.description,
        "stringlist", "",
        {
            completer: function (context) {
                context.anchored = false;
                if (params.completer)
                    params.completer(context)
            },
            domains: params.domains || function (values) values,
            has: params.has || function (val) set.has(params.set, val),
            initialValue: true,
            getter: params.getter || function () Object.keys(params.set),
            setter: function (values) {
                let newset  = set(values);
                let current = params.set;
                params.action(false, this.value.filter(function (site) !set.has(newset, site)));
                params.action(true,  values.filter(function (site) !set.has(current, site)))
                return this.value;
            },
            persist: false,
            privateData: true,
            validator: params.validator || function () true
        }));

XML.ignoreWhitespace = false;
XML.prettyPrinting   = false;
var INFO =
<plugin name="noscript" version="0.2.1"
        href="http://dactyl.sf.net/pentadactyl/plugins#noscript-plugin"
        summary="NoScript integration"
        xmlns={NS}>
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Pentadactyl" minVersion="1.0"/>
    <p>
        This plugin provides tight integration with the NoScript add-on.
        In addition to commands and options to control the behavior of
        NoScript, this plugin also provides integration with both the
        {config.appName} and {config.host} sanitization systems sorely
        lacking in the add-on itself. Namely, when data for a domain is
        purged, all of its associated NoScript permissions are purged as
        well, and temporary permissions are purged along with session
        data.
    </p>
    <note>
        As most options provided by this script directly alter NoScript
        preferences, which are persistent, their values are automatically
        preserved across restarts.
    </note>
    <item>
        <tags>'script' 'noscript'</tags>
        <strut/>
        <spec>'script'</spec>
        <type>boolean</type> <default>noscript</default>
        <description>
            <p>
                When on, all sites are allowed to execute scripts and
                load plugins. When off, only specifically allowed sites
                may do so.
            </p>
        </description>
    </item>
    <item>
        <tags>'noscript-forbid' 'nsf'</tags>
        <spec>'noscript-forbid'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The set of permissions forbidden to untrusted sites.
            </p>
            { prefs.descs("forbid") }
            <p>See also <o>noscript-objects</o>.</p>
        </description>
    </item>
    <item>
        <tags>'noscript-list' 'nsl'</tags>
        <spec>'noscript-list'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The set of items to show in the main completion list and
                NoScript menu.
            </p>
            { prefs.descs("list") }
        </description>
    </item>
    <item>
        <tags>'noscript-objects' 'nso'</tags>
        <spec>'noscript-objects'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The list of objects which allowed to display. See also
                <o>noscript-forbid</o>.
            </p>
            <example><ex>:map <k name="A-c"/></ex> <ex>:set nso!=<k name="A-Tab"/></ex></example>
        </description>
    </item>
    <item>
        <tags>'noscript-sites' 'nss'</tags>
        <spec>'noscript-sites'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The list of sites which are permanently allowed to execute
                scripts.
            </p>
            <example><ex>:map <k name="A-s"/></ex> <ex>:set nss!=<k name="A-Tab"/></ex></example>
        </description>
    </item>
    <item>
        <tags>'noscript-tempsites' 'nst'</tags>
        <spec>'noscript-tempsites'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The list of sites which are temporarily allowed to execute
                scripts. The value is not preserved across application
                restarts.
            </p>
            <example><ex>:map <k name="A-S-s"/></ex> <ex>:set nst!=<k name="A-Tab"/></ex></example>
        </description>
    </item>
    <item>
        <tags>'noscript-untrusted' 'nsu'</tags>
        <spec>'noscript-untrusted'</spec>
        <type>stringlist</type> <default></default>
        <description>
            <p>
                The list of untrusted sites which are not allowed to activate,
                nor are listed in the main completion lists or NoScript menu.
            </p>
            <example><ex>:map <k name="A-C-s"/></ex> <ex>:set nsu!=<k name="A-Tab"/></ex></example>
        </description>
    </item>
</plugin>;

/* vim:se sts=4 sw=4 et: */
