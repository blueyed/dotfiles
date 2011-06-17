INSTALL_FILES := ackrc autojump config gemrc gitconfig gitignore.global gvimrc hgrc irbrc lib oh-my-zsh pentadactyl pentadactylrc railsrc screenrc vim vimrc Xdefaults zlogin zshenv
# zshrc needs to get installed after submodules have been initialized
INSTALL_FILES_AFTER_SM := zshrc

install: install_files init_submodules install_files_after_sm

init_submodules:
	# Requires e.g. git 1.7.5.4
	git submodule update --init --recursive

install_files: $(addprefix ~/.,$(INSTALL_FILES))
install_files_after_sm: $(addprefix ~/.,$(INSTALL_FILES_AFTER_SM))
~/.%: %
	@echo ln -sfn $< $@
	test -e $@ && echo "Skipping existing target: $@" || ln -sfn ${PWD}/$< $@

install_programs:
	sudo apt-add-repository ppa:git-core/ppa
	sudo apt-get install aptitude
	sudo aptitude install console-terminus git rake vim-gnome xfonts-terminus xfonts-terminus-oblique
	# extra
	sudo aptitude install ttf-mscorefonts-installer
	# zsh
	sudo aptitude install zsh
	# changing shell to zsh
	chsh -s /usr/bin/zsh
