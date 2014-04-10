#!/usr/bin/zsh
#   NB: zsh is used for "$=" mainly, where `eval` failed to work with `trap`
#       (quoting).
#   TODO: use $call_cmd (as array for execution)
#
# Connect remotely (via SSH) to a host running weechat and tail-f/read the
# logfile containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

env | sort > /tmp/weechat-notify-from-remote.env

# Close stdin, allowing the script to be properly disowned when started from a terminal
# (otherwise it gets killed when the terminal is closed)
exec <&-

set -x

# Wrap with flock/lockfile
lockfile=/run/lock/weechat-notify-from-remote.lock
(flock -n 9 || { echo "Running already ($lockfile). Aborting."; exit 1; }

# Setup logging
logfile=/tmp/weechat-notify-from-remote.sh.log
touch $logfile
chmod 600 $logfile
log() {
  echo "[$$] $(date +'%FT%T') $@" >> $logfile
}

exec 1>$logfile
exec 2>$logfile

log "Starting..."

# Sound to play on highlight
sound_message=/usr/share/sounds/ubuntu/stereo/message-new-instant.ogg

# Export information required to play sound (via alsa/pulseaudio)
export DISPLAY=:0
export XAUTHORITY=/home/daniel/.Xauthority

# Prefer gnome-keyring?!
#export SSH_ASKPASS=ssh-askpass
#if ! ssh-add -l >/dev/null 2>&1; then ssh-add; fi

# XXX: why?
# PATH="$(dirname $0):$PATH"

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

# kill ssh, if we are killed (except for TRAP:1)
trap 'sig=$? ; echo TRAP:$sig >> $logfile ; if [ $sig -ne 1 ]; then ; echo "kill_cmd: $kill_cmd_eval" >> $logfile; eval $kill_cmd_eval ; exit ; else ; echo "continuing..." >> $logfile; fi' 0 2 3 15

export AUTOSSH_DEBUG=1
export AUTOSSH_LOGFILE=/tmp/weechat-notify-from-remote.autossh.log
export AUTOSSH_FIRST_POLL=300
export AUTOSSH_POLL=300
export AUTOSSH_PIDFILE=/tmp/weechat-notify-from-remote.autossh.pid
# NOTE: -F required for autossh, otherwise it exits immediately
tail_cmd="tail -n0 -F .weechat/logs/$(date +%Y)/perl.strmon.weechatlog"
# '-t'/'-tt' is required for ssh killing its child process.
call_cmd="autossh -tt $ssh_extra_config $userhost -- ssh -t $internalhost '$tail_cmd'"
# kill_cmd="ssh $ssh_extra_config $userhost ssh $internalhost \"pkill -f '$tail_cmd'\""
kill_cmd_eval='kill $(cat $AUTOSSH_PIDFILE)'

# export DBUS_SESSION_BUS_ADDRESS environment variable
pid_gnome_session=$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid_gnome_session/environ|cut -d= -f2-)"

# sleep_failure=5
# while true ; do
#   echo $call_cmd
#   sleep_failure=$((sleep_failure+5))
  $=call_cmd 2>>$logfile | \
    # sed -u 's/[<@&]//g' | \
    while read date time number channel nick delim message; do
      log "New message: date time number channel nick delim [message]"
      log "             $date $time $number $channel $nick $delim"
      log "             $message"

      # export DBUS_SESSION_BUS_ADDRESS environment variable
      pid_gnome_session=$(pgrep gnome-session)
      export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid_gnome_session/environ|cut -d= -f2-)"

      title="weechat: ${nick} @ ${channel}"
      body="$message"
      notify-send --category=im.received -t 0 "$title" "$body" &>>$logfile
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

#   log "Sleeping $sleep_failure seconds after read/ssh failure..."
#   sleep $sleep_failure
# done
) 9>$lockfile
