#!/usr/bin/zsh
#   NB: zsh is used for "$=" mainly, where `eval` failed to work with `trap`
#       (quoting).
#   TODO: use $call_cmd (as array for execution)
#
# Connect remotely (via SSH) to a host running weechat and tail-f/read the
# logfile containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

# Close stdin, allowing the script to be properly disowned when started from a
# terminal (otherwise it gets killed when the terminal is closed).
# No SIGHUP then.
exec <&-

zmodload zsh/datetime

# Setup logging
logfile=/tmp/weechat-notify-from-remote.sh.log
touch $logfile
chmod 600 $logfile
log() {
  echo "[$0:$$] $(date +'%FT%T') $@" >> $logfile
}

log "Starting... PID: $$"

# Wrap with flock/lockfile
lockfile=/run/user/$UID/lock/weechat-notify-from-remote.lock
mkdir -p "$(dirname $lockfile)"
(flock -n 9 || {
  msg="Running already ($lockfile). Aborting."
  echo $msg
  log $msg
  exit 1
}

# Copy/duplicate stdout/stderr into logfile when running in a terminal
# (descriptor 1 (stdout) is opened on a terminal).
if [[ -t 1 ]]; then
  exec >  >(tee -a $logfile)
  exec 2> >(tee -a $logfile >&2)
else
  exec >>  $logfile
  exec 2>> $logfile
fi

# Sound to play on highlight
sound_message=/usr/share/sounds/ubuntu/stereo/message-new-instant.ogg

# Export information required to play sound (via alsa/pulseaudio)
# export DISPLAY=:0
# export XAUTHORITY=/home/daniel/.Xauthority

# Grab the display and xauthority cookie.
w=$(w -h -s | grep ':[0-9]\W' | head -1 | tr -s ' ')
export DISPLAY=$(echo $w | cut -d\  -f2)
X_USER=$(echo $w | cut -d\  -f1)
export XAUTHORITY=/home/$X_USER/.Xauthority

# User and hosts information, encrypted.
userhost=$(dotfiles-decrypt 'U2FsdGVkX1+qm0Yw5PFoEgQ6dt77wSfKmpqSQXR/u8Fq1jot4M9SLmcInAuq1XGZ')
internalhost=$(dotfiles-decrypt 'U2FsdGVkX1+t47mSzfhcSOzSjC73h5kGVDPbDhbXzRk=')
ssh_extra_config=($(dotfiles-decrypt 'U2FsdGVkX1/b6mo1MxltGbfTDs1xWhXRZEoLa/yx3iI2MaanXf0aKkwrGa0epC8ybDgU03Qc4JjXHz/6Q4U/ZA==')) # remote port forwarding etc

# Make autossh aware of port-forwarding failures, requires AUTOSSH_GATETIME=0.
# TODO: would be nice to handle missing ssh-agent better (in case you abort the dialog multiple times).
ssh_extra_config+=(-o ExitOnForwardFailure=yes -o IdentitiesOnly=yes)

# # this might be used to override $autossh_weechat_port
# test -f ~/.dotfiles/dotfilesrc && source ~/.dotfiles/dotfilesrc
#
# if [ x$autossh_weechat_port = x ]; then
#   # autogenerate port based on hostname
#   port_offset="$(sumcharvals $(hostname))"
#   autossh_weechat_port=$(( 20000 + port_offset ))
# fi

setopt TRAPS_ASYNC  # kill running programs, with traps setup.
_trap() {
  local ret=$?
  local sig=$1
  echo "TRAP:$functrace (ret=$ret, sig=$sig)" >> $logfile
  if [[ $sig != 1 ]]; then
    log "Calling kill_cmd: $kill_cmd_eval"
    eval $kill_cmd_eval
    if [[ $sig != 0 ]] && [[ -f $lockfile ]]; then
      rm $lockfile
    fi
    exit $sig
  else
    log "continuing..."
  fi
}
trap _trap 0 2 3 15

# NOTE: sleep in 1 second steps to allow the process to be killed (via trap) when logging out.
# This is required for it to be restarted anew on re-login for the new gnome-keyring-daemon.
my_sleep() {
  i=$(expr $1 + 1)
  while i=$(expr $i - 1); do
    sleep 1
  done
}

export AUTOSSH_DEBUG=1
export AUTOSSH_LOGFILE=$logfile
export AUTOSSH_FIRST_POLL=300
export AUTOSSH_POLL=600
export AUTOSSH_PIDFILE=/tmp/weechat-notify-from-remote.autossh.$$.pid
export AUTOSSH_MAXSTART=1
export AUTOSSH_GATETIME=0  # for "-o ExitOnForwardFailure=yes"
export AUTOSSH_PORT=0
# NOTE: -F required for autossh, otherwise it exits immediately
tail_cmd="tail -n0 -F .weechat/logs/$(date +%Y)/perl.strmon.weechatlog"
# '-t'/'-tt' is required for ssh killing its child process.
call_cmd=(envoy-exec autossh -tt $ssh_extra_config $userhost -- ssh -t $internalhost $tail_cmd)
# NOTE: "kill -9" might be necessary if ssh aborts because of ExitOnForwardFailure
#       and autossh has not setup its signal handler in that case (reported as bug).
kill_cmd_eval='test -f $AUTOSSH_PIDFILE \
  && { kill $(cat $AUTOSSH_PIDFILE); sleep 1; \
       test -f $AUTOSSH_PIDFILE && kill -9 $(cat $AUTOSSH_PIDFILE); }'

# Test for network.
while true; do
  if ping -q -c1 -w2 heise.de; then
    break
  fi
  log "Waiting for network connection.."
  my_sleep 10
done


sleep_failure=5
max_sleep_failure=120
while true ; do
  echo "Running: $call_cmd"
  sleep_failure=$((sleep_failure * 2))
  if (( sleep_failure > max_sleep_failure )); then
    sleep_failure=$max_sleep_failure
  fi
  ts_last_read=0
  $call_cmd | { \
    # sed -u 's/[<@&]//g' | \
    while read date time number channel nick delim message; do

      # Ignore Twitter rebooting its service, which would re-display the last X
      # Twitter highlights again.
      ts_this_read=$EPOCHSECONDS
      if (( ts_this_read - ts_last_read <= 5 )); then
        if [ "$channel" = "bitlbee.#twitter_blueyed" ]; then
          notify-send "weechat-notify: ignoring twitter reboot"
          continue
        fi
      fi

      log "New message: date time number channel nick delim [message]"
      log "             $date $time $number $channel $nick $delim"
      log "             $message"

      # Export DBUS_SESSION_BUS_ADDRESS environment variable for notify-send,
      # based on the gnome-session PID for the current user (newest).
      pid_gnome_session=$(pgrep -u $UID -n gnome-session)
      export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/${pid_gnome_session}/environ|cut -d= -f2-)"

      # Notification.
      title="weechat: ${nick} @ ${channel}"
      body="$message"
      notify-send --category=im.received -t 0 "$title" "$body" &>>$logfile

      # Sound: only once per 5 seconds.
      # if [[ -n "$sound_message" ]] && (( ts_this_read - ts_last_read > 5 )); then
      #   if command -v play >/dev/null 2>&1 ; then
      #     log "Playing sound: $sound_message"
      #     play -q "$sound_message" &
      #   fi
      # fi

      sleep_failure=5
      ts_last_read=$ts_this_read
    done
  }

  # break  # trust autossh to only exit with SIGTERM etc.

  log "Sleeping $sleep_failure seconds after read/ssh failure..."
  my_sleep $sleep_failure
done
) 9>$lockfile
