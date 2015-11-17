# Settings for debugging.
DRYRUN?=0
DRYRUN_COND:=$(if $(DRYRUN),echo DRY: ,)
DEBUG=
VERBOSE=1

INSTALL_FILES := ackrc agignore aptitude/config \
	$(wildcard bazaar/plugins/*) \
	$(filter-out bazaar/plugins,$(wildcard bazaar/*)) \
	ctags \
	$(wildcard fonts/*) gemrc gitconfig gitattributes.global gitignore.global \
	hgrc irbrc oh-my-zsh pbuilderrc pdbrc pentadactyl \
	pentadactylrc railsrc \
	sackrc screenrc screenrc.common subversion/servers \
	terminfo tigrc tmux.conf tmux.common.conf vim vimrc vimpagerrc Xresources \
	xprofile \
	config/mc/ini \
	config/gnome-session/sessions \
	$(filter-out config/mc config/gnome-session, $(wildcard config/*)) \
	$(wildcard local/share/applications/*) \
	$(patsubst %/,%,sort $(dir $(wildcard urxvt/ext/*/)))

REMOVED_FILES:=pastebinit.xml config/lilyterm/default.conf

# zshrc needs to get installed after submodules have been initialized
INSTALL_FILES_AFTER_SM := zshenv zshrc

# first install/update, and than migrate (might update submodules to be removed)
default: install migrate

install_files: install_files_before_sm install_files_after_sm
install: install_files_before_sm init_submodules install_files_after_sm

# Migrate existing dotfiles setup
migrate: .stamps .stamps/migrate_byobu.2 .stamps/dangling.1 .stamps/submodules_rm.20
migrate: .stamps/neobundle.1
migrate: .stamps/remove-byobu
migrate: .stamps/remove-autojump
migrate: .stamps/rename-xsessionrc-xprofile
migrate: check_removed_files
check_removed_files:
	@for i in $(REMOVED_FILES); do \
		target=~/.$$i; \
		if [ -L $$target ] && ! [ -f $$target ]; then \
			echo "NOTE: found obsolete/removed file (dangling symlink): $$target"; \
		fi \
	done

.stamps:
	mkdir -p .stamps
.stamps/migrate_byobu.2:
	@# .local/share/byobu is handled independently (preferred), only use ~/.byobu
	$(RM) -r ~/.local/share/byobu
	$(RM) ~/.byobu/keybindings ~/.byobu/profile ~/.byobu/profile.tmux ~/.byobu/status ~/.byobu/statusrc
	$(RM) .stamps/migrate_byobu.*
	touch $@
.stamps/dangling.1:
	for i in ~/.byobu ~/.byoburc ~/.sh ~/.bin ~/.vimperator ~/.vimperatorrc ~/.gitignore ; do \
		test -h "$$i" && { test -e "$$i" || $(RM) "$$i" ; } || true ; \
	done
	touch $@
.stamps/submodules_rm.20:
	rm_bundles="vim/bundle/DBGp-Remote-Debugger-Interface vim/bundle/dbext vim/bundle/xdebug vim/bundle/taglist vim/bundle/autocomplpop vim/bundle/tplugin vim/bundle/powerline vim/bundle/snipmate-snippets vim/bundle/autoclose vim/bundle/zoomwin vim/bundle/snippets vim/bundle/outlook lib/git-meld vim/bundle/powerline-vim vim/bundle/occur vim/vendor/UltiSnips vim/bundle/colorscheme-gruvbox config/awesome/awpomodoro vim/bundle/isort vim/bundle/targets lib/legit"; \
	for i in $$rm_bundles; do \
		[ ! -d "$$i" ] || [ ! -e "$$i/.git" ] && continue ; \
		( cd $$i && gst=$$(git status --short --untracked-files=normal 2>&1) && [ "$$gst" = "" ] || { echo "Repo not clean ($$i): $$gst" ; false ; } ; ) \
			&& $(RM) -r $$i \
			|| { echo "Skipping removal of submodule $$i" ; } ; \
	done
	touch $@
.stamps/neobundle.1:
	@echo '== Migrating to neobundles =='
	@echo Use the following to inspect any changes to vim/pathogen submodules:
	@echo 'cd vim/bundle; for i in $$(git ls-files -o); do echo $$i; ( test -f $$i && (git diff --exit-code;) || ( cd $$i && git diff --exit-code; ) ) || break; done'
	@echo To delete all untracked bundles:
	@echo 'rm $$(git ls-files -o vim/bundle) -r'
	touch $@
.stamps/remove-byobu:
	@echo "== byobu has been removed =="
	@echo "You should 'rm ~/.byobu -rf' manually."
	touch $@
.stamps/remove-autojump:
	@echo "== autojump has been removed =="
	@echo "You should 'rm ~/.autojump ~/.local/share/autojump -rf' manually."
	touch $@
.stamps/rename-xsessionrc-xprofile:
	@echo "== .xsessionrc has been moved to .xprofile =="
	@echo "You should 'rm -i ~/.xsessionrc manually."
	touch $@

# Target to install a copy of .dotfiles, where Git is not available
# (e.g. distributed with rsync)
install_checkout: install_files install_files_after_sm

# Handle Git submodules
init_submodules: update_submodules
update_submodules: sync_submodules
	@# Requires e.g. git 1.7.5.4
	git submodule update --init --quiet
	@# Simulate `--recursive`, but not for vim/bundle/command-t:
	@# (https://github.com/wincent/Command-T/pull/23)
#	cd vim/bundle/operator-replace && git submodule update --init --quiet
#	cd vim/bundle/operator-user && git submodule update --init --quiet
#	cd vim/bundle/YouCompleteMe && git submodule update --init --quiet
sync_submodules:
	git submodule sync --quiet

ALL_FILES := $(INSTALL_FILES) $(INSTALL_FILES_AFTER_SM)

# Add dirs additionally with trailing slash removed.
ALL_FILES := $(sort $(ALL_FILES) $(patsubst %/,%,$(ALL_FILES)))

.PHONY: $(ALL_FILES)

install_files_before_sm: $(addprefix ~/.,$(INSTALL_FILES))
install_files_after_sm: $(addprefix ~/.,$(INSTALL_FILES_AFTER_SM))

define func-install
$(if $(DEBUG),,@){ test -h $(1) && test -e $(1) && $(if $(VERBOSE),echo "Already installed: $(1)",); } \
		|| { test -f $(1) && echo "Skipping existing target (file): $(1)"; } \
		|| { test -d $(1) && echo "Skipping existing target (dir): $(1)"; } \
		|| { test ! -e "$(2)" && echo "Target does not exist: $(2)" ; } \
		|| { $(DRYRUN_COND) mkdir -p $(shell dirname $(1)) \
			&& $(DRYRUN_COND) ln -sfn --relative $(2) $(1) \
			&& echo "Installed symlink: $(1)" ; }
endef

# install_files handler: test for (existing) symlinks, skipping existing files/dirs.
~/.%: %
	$(call func-install,$@,${CURDIR}/$<)

# Target from the source files.
$(ALL_FILES):
	$(call func-install,~/.$@,$@)

diff_files: $(ALL_FILES)
	@for i in $^ ; do \
		test -h "$$HOME/.$$i" && continue; \
		echo ===== $$HOME/.$$i $(CURDIR)/$$i ================ ; \
		ls -lh "$$HOME/.$$i" "$(CURDIR)/$$i" ; \
		if cmp "$$HOME/.$$i" "$(CURDIR)/$$i" ; then \
			echo "Same contents." ; \
		else \
		  diff -u "$$HOME/.$$i" "$(CURDIR)/$$i" ; \
		fi ; \
		printf "Replace regular file/dir ($$HOME/.$$i) with symlink? (y/n) " ; \
		read yn ; \
		if [ "x$$yn" = xy ]; then \
			command rm -rf "$$HOME/.$$i" ; \
			ln -sfn "$(CURDIR)/$$i" "$$HOME/.$$i" ; \
		fi \
	done

setup_full: setup_ppa install_programs install_zsh setup_zsh

setup_ppa:
	# TODO: make it work with missing apt-add-repository (Debian Squeeze)
	sudo apt-add-repository ppa:git-core/ppa

install_programs:
	sudo apt-get update
	sudo apt-get install aptitude
	sudo aptitude install console-terminus git rake vim-gnome xfonts-terminus xfonts-terminus-oblique exuberant-ctags
	# extra
	sudo aptitude install ttf-mscorefonts-installer
install_zsh:
	sudo aptitude install zsh
install_commandt_module:
	cd ~/.dotfiles/vim/bundle/command-t && \
		rake make


install_programs_rpm: install_zsh_rpm
	sudo yum install git rubygem-rake ctags
install_zsh_rpm:
	sudo yum install zsh

ZSH_PATH := /bin/zsh
ifneq ($(wildcard /usr/bin/zsh),)
	ZSH_PATH := /usr/bin/zsh
endif
ifneq ($(wildcard /usr/local/bin/zsh),)
	ZSH_PATH := /usr/local/bin/zsh
endif

setup_sudo:
	@user_file=/etc/sudoers.d/$$USER ; \
	if [ -e $$user_file ] ; then \
		echo "$$user_file exists already." ; exit 1 ; \
	fi ; \
	printf '# sudo config for %s\nDefaults:%s !tty_tickets,timestamp_timeout=60\n' $$USER $$USER | sudo tee $$user_file.tmp > /dev/null \
		&& sudo chmod 440 $$user_file.tmp \
		&& sudo visudo -c -f $$user_file.tmp \
		&& sudo mv $$user_file.tmp $$user_file

setup_zsh:
	@# Check that ZSH_PATH is listed in /etc/shells
	@grep -qF "${ZSH_PATH}" /etc/shells || { \
		echo "Adding ${ZSH_PATH} to /etc/shells" ; \
		echo "${ZSH_PATH}" | sudo tee -a /etc/shells > /dev/null ; \
	}
	@if [ "$(shell getent passwd $$USER | cut -f7 -d:)" != "${ZSH_PATH}" ]; then \
		chsh -s ${ZSH_PATH} ; \
	fi
	@# obsolete/buggy?!:	-o "$(shell zsh -i -c env|grep '^ZSH=')" != "" ]

# Upgrade all submodules
upgrade:
	rake upgrade

tags:
	# ctags -R --exclude=YouCompleteMe .
	# ag --ignore YouCompleteMe -g . | ctags --links=no -L-
	ag -g . | ctags --links=no -L-
.PHONY: tags
