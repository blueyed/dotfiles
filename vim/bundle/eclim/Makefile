compare:
	for i in $$(git ls-files --modified eclim); do \
		b=~/src/eclim/org.eclim*/vim/$$i; \
		cmp $$i $$b && continue; \
		bcompare $$i $$b; \
	done
