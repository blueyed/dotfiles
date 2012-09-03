#!/usr/bin/zsh
#   NB: zsh is used for "$=" mainly, where `eval` failed to work with `trap`
#       (quoting).
#
# Connect remotely (via SSH) to a host running weechat and tail-f/read the
# logfile containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

# Sound to play on highlight
sound_message=/usr/share/sounds/ubuntu/stereo/message-new-instant.ogg

# Export information required to play sound (via alsa/pulseaudio)
export DISPLAY=:0
export XAUTHORITY=/home/daniel/.Xauthority

export SSH_ASKPASS=ssh-askpass
if ! ssh-add -l >/dev/null 2>&1; then ssh-add; fi

# XXX: why?
PATH="$(dirname $0):$PATH"

logfile=/tmp/log.weechat
touch $logfile
chmod 600 $logfile

# # user and hosts information, encrypted.
userhost=$(dotfiles-decrypt 'U2FsdGVkX1+qm0Yw5PFoEgQ6dt77wSfKmpqSQXR/u8Fq1jot4M9SLmcInAuq1XGZ')
internalhost=$(dotfiles-decrypt 'U2FsdGVkX1+t47mSzfhcSOzSjC73h5kGVDPbDhbXzRk=')
ssh_extra_config=$(dotfiles-decrypt 'U2FsdGVkX1831ASVSASVEdbccoXHM4T9QzI2Jk0KGvimOGjCKkN90lE2v61SrfCVNNwdQ9Lcr2kKl8k2PUS3lA==') # remote port forwarding etc

# # this might be used to override $autossh_weechat_port
# test -f ~/.dotfiles/dotfilesrc && source ~/.dotfiles/dotfilesrc
#
# if [ x$autossh_weechat_port = x ]; then
#   # autogenerate port based on hostname
#   port_offset="$(sumcharvals $(hostname))"
#   autossh_weechat_port=$(( 20000 + port_offset ))
# fi

trap 'sig=$? ; echo TRAP:$sig >> $logfile ; if [ $sig -ne 1 ]; then $=kill_cmd ; exit ; fi' 0 2 3 15

tail_cmd="tail -n0 -f .weechat/logs/$(date +%Y)/perl.strmon.weechatlog"
call_cmd="ssh $ssh_extra_config $userhost ssh $internalhost '$tail_cmd'"
kill_cmd="ssh $ssh_extra_config $userhost ssh $internalhost \"pkill -f '$tail_cmd'\""

date >> $logfile
echo "Starting loop in $0..." >> $logfile

sleep_failure=0
while true ; do
  sleep_failure=$((sleep_failure+1))
  $=call_cmd 2>>$logfile | \
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

      if [ -n "$sound_message" ]; then
        if command -v play >/dev/null 2>&1 ; then
          play "$sound_message"
        fi
      fi
      sleep_failure=0 # reset on successful read
    done

  echo "Sleeping $sleep_failure seconds after read/ssh failure..." >> $logfile
  sleep $sleep_failure
done
