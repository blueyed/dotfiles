. ~/.zsh/config
. ~/.zsh/aliases
. ~/.zsh/completion

# source files (no dirs)
. ~/.sh/source.d/*(.)


# Options
# TODO: move to single file/dir (conf.d?)
setopt PRINT_EXIT_VALUE
# Ctrl-D (^D) logs out
unsetopt IGNORE_EOF


# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && .  ~/.localrc
