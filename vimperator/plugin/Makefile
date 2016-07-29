# List of installed "official" plugins from
# http://5digits.org/pentadactyl/plugins#sect-official-plugins
DACTYL_PLUGINS := browser-improvements curl http-headers jQuery jscompletion noscript

PLUGINS := noscript-interactive.js

all: update

noscript-interactive.js:
	curl -s https://raw.githubusercontent.com/ervandew/vimperator-plugins/master/plugin/noscript.js > $@

dactyl_plugins:
	for f in $(DACTYL_PLUGINS); do \
		wget http://5digits.org/plugins/$$f-dev.js -O $$f.js; \
	done

update: dactyl_plugins $(PLUGINS)
