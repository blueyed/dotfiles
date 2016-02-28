#!/bin/sh
# Connect remotely (via SSH) to a host running weechat and tail-f/read the
# logfile containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

DAEMON_RELAY=/run/user/$UID/weechat.relay
DAEMON_LOCKFILE=/run/user/$UID/weechat.daemon.lock

log() {
  echo "[$$/$DISPLAY] $(date +'%FT%T') $@"
}

# Wrap with flock (for daemon).
mkdir -p "$(dirname $DAEMON_LOCKFILE)"
if [ "${FLOCKER}" != "$0" ]; then
  echo "Ensure that daemon is running.."
  env FLOCKER="$0" flock -n -E 23 "$DAEMON_LOCKFILE" "$0" "$@" &

  # Sound to play on highlight
  sound_message=
  for f in /usr/share/sounds/freedesktop/stereo/message-new-instant.oga \
      /usr/share/sounds/ubuntu/stereo/message-new-instant.ogg; do
    if [ -f "$f" ]; then
      sound_message="$f"
      break
    fi
  done
  if [ -z "$sound_message" ]; then
    echo "No sound file found!" >&2
  fi

  if [ -z "$DISPLAY" ]; then
    # Grab the display and xauthority cookie.
    w=$(w -h -s | grep ':[0-9]\W' | head -1 | tr -s ' ')
    export DISPLAY="$(echo $w | cut -d\  -f2)"
    X_USER="$(echo $w | cut -d\  -f1)"
    export XAUTHORITY="/home/$X_USER/.Xauthority"
  fi
  if [ -z "$DISPLAY" ]; then
    echo "No DISPLAY available.  Aborting." >&2
    exit 1
  fi

  echo "Watching/tailing $DAEMON_RELAY.."
  ts_last_read=0
  tail -n0 -F $DAEMON_RELAY | while read date time number channel nick delim message; do
    # sed -u 's/[<@&]//g' | \

    # Ignore Twitter rebooting its service, which would re-display the last X
    # Twitter highlights again.
    ts_this_read=$(date +%s)
    if (( ts_this_read - ts_last_read <= 5 )); then
      if [ "$channel" = "bitlbee.#twitter_blueyed" ]; then
        notify-send "weechat-notify: ignoring twitter reboot"
        continue
      fi
    fi

    log "New message: date time number channel nick delim [message]"
    log "'$date' '$time' '$number' '$channel' '$nick' '$delim'"
    log "'$message'"

    # Notification.
    title="weechat: ${nick} @ ${channel}"
    body="$message"
    notify-send --category=im.received -t 0 "$title" "$body ($DISPLAY)"

    # Sound: only once per 5 seconds.
    if [[ -n "$sound_message" ]] && (( ts_this_read - ts_last_read > 5 )); then
      if command -v play >/dev/null 2>&1 ; then
        log "Playing sound: $sound_message"
        # NOTE: amplified 5x to be hearable with music playing.
        play --volume 5 -q "$sound_message" &
      fi
    fi

    sleep_failure=5
    ts_last_read=$ts_this_read
  done
  exit
fi

log "Starting daemon: PID: $$"

# User and hosts information, encrypted.
userhost=$(dotfiles-decrypt 'U2FsdGVkX1+qm0Yw5PFoEgQ6dt77wSfKmpqSQXR/u8Fq1jot4M9SLmcInAuq1XGZ')
internalhost=$(dotfiles-decrypt 'U2FsdGVkX1+t47mSzfhcSOzSjC73h5kGVDPbDhbXzRk=')
ssh_extra_config="$(dotfiles-decrypt 'U2FsdGVkX1/b6mo1MxltGbfTDs1xWhXRZEoLa/yx3iI2MaanXf0aKkwrGa0epC8ybDgU03Qc4JjXHz/6Q4U/ZA==')"  # remote port forwarding etc

# -o ExitOnForwardFailure=yes: Make autossh aware of port-forwarding failures, requires AUTOSSH_GATETIME=0.
# -o BatchMode=yes is required for ssh to not ask for a password (via tty).
ssh_extra_config="$ssh_extra_config -o ExitOnForwardFailure=yes -o IdentitiesOnly=yes -o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=2"

# NOTE: sleep in 1 second steps to allow the process to be killed (via trap) when logging out.
# This is required for it to be restarted anew on re-login for the new gnome-keyring-daemon.
my_sleep() {
  log "Sleeping for $1 seconds.."
  i=$(expr $1 + 1)
  while i=$(expr $i - 1); do
    sleep 1
  done
}

# Test for network.
while true; do
  if ping -q -c1 -w2 heise.de; then
    break
  fi
  log "Waiting for network connection.."
  my_sleep 10
done

tail_cmd="tail -n0 -F .weechat/logs/$(date +%Y)/perl.strmon.weechatlog"
# '-t'/'-tt' was required for ssh killing its child process.
# Not anymore with cat-trick (http://unix.stackexchange.com/questions/40023/get-ssh-to-forward-signals/196657#196657).
call_cmd="ssh $ssh_extra_config $userhost -- ssh $internalhost '$tail_cmd < <(cat; kill -INT 0)' <&1"

trap "pkill -TERM -P $$" 0

sleep_failure=5
max_sleep_failure=120
while true ; do
  echo "Running: $call_cmd"
  $call_cmd > $DAEMON_RELAY

  log "Sleeping $sleep_failure seconds after read/ssh failure..."
  my_sleep $sleep_failure
  sleep_failure=$(( (sleep_failure+1) * 12 / 10 ))
  if (( sleep_failure > max_sleep_failure )); then
    sleep_failure=$max_sleep_failure
  fi
done
