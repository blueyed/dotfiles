#!/bin/sh
# 
# Connect remotely (via SSH) to a host running weechat and tail-f/read the logfile
# containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

export SSH_ASKPASS=ssh-askpass
if ! ssh-add -l >/dev/null 2>&1; then ssh-add; fi

PATH="$(dirname $0):$PATH"

logfile=/tmp/log.weechat
touch $logfile
chmod 600 $logfile

# user and hosts information, encrypted.
userhost=$(dotfiles-decrypt 'U2FsdGVkX1/IGyB2mLXvSSKSNFs/J8d7FiQwB2fx9HWU9w+1L9+v3SfWzYpkLlbk')
internalhost=$(dotfiles-decrypt 'U2FsdGVkX1+t47mSzfhcSOzSjC73h5kGVDPbDhbXzRk=')

# this might be used to override $autossh_weechat_port
test -f ~/.dotfiles/dotfilesrc && source ~/.dotfiles/dotfilesrc

if [ x$autossh_weechat_port = x ]; then
  # autogenerate port based on hostname
  port_offset="$(sumcharvals $(hostname))"
  autossh_weechat_port=$(( 20000 + port_offset ))
fi

date >> $logfile
echo "Starting loop in $0..." >> $logfile

while true ; do
    autossh -M $autossh_weechat_port $userhost \
      ssh $internalhost "tail -n0 -f .weechat/logs/perl.strmon.weechatlog" < /dev/null | \
        # sed -u 's/[<@&]//g' | \
        while read date time number channel nick delim message; do
          echo "== $(date) ==" >> $logfile
          echo date time number channel nick delim message >> $logfile
          echo "$date" "$time" "$number" "$channel" "$nick" "$delim" "$message" >> $logfile

          title="${nick} @ ${channel}"
          body="$message"
          notify-send --category=im.received -t 15000 "$title" "$body"
          # kdialog --passivepopup  "${message}" --title "${nick} @ ${channel}" 30
          # zenity --info --title "${nick} @ ${channel}" --timeout 30 --text "${message}" 
          # nervt, irgendwie einschränken:
          #       ogg123 /usr/share/sounds/KDE-Sys-App-Message.ogg
        done

  echo "Sleeping 30 seconds after read failure..." >> $logfile
  sleep 30
done
