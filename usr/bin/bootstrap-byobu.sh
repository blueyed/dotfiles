#!/bin/sh
#
# This script is meant to bootstrap byobu remotely.
# This is used by e.g. byobu-on-host.

debug() {
  # echo "$@"
  :
}

# test -f /etc/profile && source /etc/profile

# Try using SHELL=zsh if it can be found
if [ $SHELL != "zsh" ]; then
  if ! which zsh > /dev/null 2>&1; then
    if [ -x /opt/bin/zsh ]; then
      SHELL=/opt/bin/zsh
    fi
  else
    SHELL="$(which zsh)"
  fi
fi

BYOBU_PREFIX="$HOME/.dotfiles/lib/byobu/usr"
BYOBU_BACKEND=tmux
PATH="$BYOBU_PREFIX/bin:$PATH"

if ! type $BYOBU_BACKEND >/dev/null ; then
  if [ -x /opt/bin/$BYOBU_BACKEND ]; then
    PATH=/opt/bin:$PATH
  fi
fi

debug "Using SHELL: $SHELL"
debug "Using PATH:  $PATH"

# exec $SHELL -xv -c $BYOBU_PREFIX/bin/byobu
exec $SHELL -c $BYOBU_PREFIX/bin/byobu
