INSTALL_FILES := ackrc autojump config gemrc gitconfig gitignore.global gvimrc hgrc irbrc lib oh-my-zsh pentadactyl pentadactylrc railsrc screenrc vim vimrc zlogin zshenv zshrc

install: $(addprefix ~/.,$(INSTALL_FILES))
	git submodule init
	git submodule update --recursive

~/.%: %
	@echo ln -sfn $< $@
	test -e $@ && echo "Skipping existing target: $@" || ln -sfn ${PWD}/$< $@

install_programs:
	sudo aptitude install console-terminus git rake vim-gnome xfonts-terminus xfonts-terminus-oblique zsh
