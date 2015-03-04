# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# This gets executed for i3wm, via gnome-session.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add ~/.dotfiles/usr/bin
if [ -d "$HOME/.dotfiles/usr/bin" ] ; then
    PATH="$HOME/.dotfiles/usr/bin:$PATH"
fi

# For pipsi:
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Setup minimal pyenv environemt, to make it available for e.g. firefox started from awesome, calling gvim.
# Also done in ~/.zshenv.
if [ -d ~/.pyenv ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  PATH="$PYENV_ROOT/bin:$PATH"

  # Setup pyenv function and completion.
  # NOTE: moved from ~/.zshrc to fix YouCompleteMe/Python in gvim started from Firefox.
  # XXX: probably not that lazy with this forking..
  if ! type pyenv | grep -q function; then # only once!
    if [ -n "$commands[pyenv]" ] ; then
      eval "$($PYENV_ROOT/bin/pyenv init -)"
    fi
  fi
fi

# Enable core files (if apport ignores the crash, e.g. for Vim).
# 1048576 blocks =~ 512mb
ulimit -c 1048576

if [ -e /home/daniel/.nix-profile/etc/profile.d/nix.sh ]; then . /home/daniel/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
