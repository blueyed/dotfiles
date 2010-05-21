. ~/.zsh/config
. ~/.sh/aliases
. ~/.zsh/completion

# source files (no dirs)
. ~/.sh/source.d/*(.)

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && .  ~/.localrc
