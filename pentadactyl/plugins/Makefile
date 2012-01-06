# List of installed "official" plugins from
# http://dactyl.sourceforge.net/pentadactyl/plugins#browser-improvements-plugin
DACTYL_PLUGINS := browser-improvements curl http-headers jscompletion noscript tab-options

update:
	for f in $(DACTYL_PLUGINS); do \
		wget http://dactyl.sourceforge.net/plugins/$$f-dev.js -O $$f.js; \
	done

