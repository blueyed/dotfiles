# ~/.profile: sourced by login shells and display managers.

# Adjust PATH.
# For pipsi:
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.dotfiles/usr/bin" ] && PATH="$HOME/.dotfiles/usr/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

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
    # Unset PYENV_SHELL=lightdm-session.  It will use $SHELL then by default.
    unset PYENV_SHELL
  fi
fi

# Enable core files (if apport ignores the crash, e.g. for Vim).
# 1048576 blocks =~ 512mb
# NOTE: controlled via /etc/security/limits.conf ?! (2015-05-05).
# ulimit -c 1048576

# Disable XON/XOFF flow control; this is required to make C-s work in Vim.
# NOTE: also in ~/.zshrc, to fix display issues during Vim startup (with
# subshell/system call).
stty -ixon 2>/dev/null

# Nix/NixOS.
# Ref: https://github.com/NixOS/nixpkgs/issues/6698
# export GTK_PATH="$GTK_PATH:$HOME/.nix-profile/lib/gtk-2.0:/usr/lib/gtk-2.0"
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


# For bash as a login-shell, also source ~/.bashrc (skipped then).
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# vim: ft=sh
