. ~/.zsh/config
. ~/.zsh/aliases
. ~/.zsh/completion

# source files (no dirs)
. ~/.zsh/source.d/*(.)

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && .  ~/.localrc
