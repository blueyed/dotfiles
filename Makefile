INSTALL_FILES := ackrc autojump config gemrc gitconfig gitignore.global gvimrc hgrc irbrc lib oh-my-zsh pentadactyl pentadactylrc railsrc screenrc sh vim vimrc zlogin zshenv zshrc

install: $(addprefix ~/.,$(INSTALL_FILES))

~/.%: %
	@echo ln -sfn $< $@
	test -e $@ && echo "Skipping existing target: $@" || ln -sfn ${PWD}/$< $@
