INSTALL_FILES := ackrc autojump config gemrc gitconfig gitignore.global gvimrc hgrc irbrc lib oh-my-zsh pdbrc pentadactyl pentadactylrc railsrc screenrc vim vimrc Xresources zlogin zshenv
# zshrc needs to get installed after submodules have been initialized
INSTALL_FILES_AFTER_SM := zshrc

install: install_files init_submodules install_files_after_sm

# Target to install a copy of .dotfiles, where Git is not available
# (e.g. distributed with rsync)
install_checkout: install_files install_files_after_sm

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
	sudo apt-get update
	sudo apt-get install aptitude
	sudo aptitude install console-terminus git rake vim-gnome xfonts-terminus xfonts-terminus-oblique exuberant-ctags
	# extra
	sudo aptitude install ttf-mscorefonts-installer
	sudo aptitude install zsh

install_programs_rpm:
	sudo yum install git rubygem-rake ctags zsh

ZSH_PATH := /usr/bin/zsh
ifneq ($(wildcard /bin/zsh),)
	ZSH_PATH := /bin/zsh
endif

setup: setup_zsh
setup_zsh:
	# changing shell to zsh, if $$ZSH is empty (set by oh-my-zsh/dotfiles)
	[ "${ZSH}" != "" ] || chsh -s $(ZSH_PATH)
