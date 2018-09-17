#!/bin/sh
# Connect remotely (via SSH) to a host running weechat and tail-f/read the
# logfile containing any highlights.
# For any new highlights/mentions a notification gets displayed (locally).

set -x

uid="$(id -u)"
DAEMON_RELAY="/run/user/$uid/weechat.relay"
LOCKFILE_CLIENT="/run/user/$uid/weechat.client$DISPLAY.lock"
LOCKFILE_DAEMON="/run/user/$uid/weechat.daemon.lock"

log() {
  echo "[$$/$DISPLAY/${FLOCKER##*-}] $(date +'%FT%T') $*"
}

# Wrap with flock (for daemon).
mkdir -p "$(dirname "$LOCKFILE_DAEMON")"
if [ -z "${FLOCKER}" ]; then
  log "Ensure that daemon is running.."
  env FLOCKER="${0}-daemon" flock -n -E 23 "$LOCKFILE_DAEMON" "$0" "$@" &

  env FLOCKER="${0}-client" flock -n -E 23 "$LOCKFILE_CLIENT" "$0" "$@"
  ret=$?
  if [ "$ret" = 23 ]; then
    log "Client already running: $LOCKFILE_CLIENT!"
  fi
  exit $ret
fi

if [ "${FLOCKER%-daemon}" != "$FLOCKER" ]; then  # {{{1
  log "Starting daemon: PID: $$"

  # User and hosts information, encrypted.
  userhost=$(dotfiles-decrypt 'U2FsdGVkX18AauACIM8Mr+WbHUtnbSo2Nrrzb5ZfD7c8zR4MNQOCqxek5ReWskSe')
  internalhost=$(dotfiles-decrypt 'U2FsdGVkX18AwDQM95e39Zrc28EYpQSeLiShk9rr5HM=%')
  ssh_extra_config="$(dotfiles-decrypt 'U2FsdGVkX1+3AASjC7+TYOQiT2ljBzLz3GaATQqTXimyOdjdz/spgy4ozUcGbfA91iorN8ikeWncozyIpalwYA==%')"  # remote port forwarding etc

  # NOTE: sleep in 1 second steps to allow the process to be killed (via trap) when logging out.
  # This is required for it to be restarted anew on re-login for the new gnome-keyring-daemon.
  my_sleep() {
    set +x
    log "Sleeping for $1 seconds.."
    i="$1"
    while true; do
      i="$((i - 1))"
      if [ "$i" -eq 0 ]; then
        break
      fi
      sleep 1
    done
    set -x
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
  # But does not work (instantly at least) on lost network connection.
  # TODO: re-add the killing of any existing port forwarding?!
  # -o ExitOnForwardFailure=yes: Make autossh aware of port-forwarding failures, requires AUTOSSH_GATETIME=0.
  # -o BatchMode=yes is required for ssh to not ask for a password (via tty).
  # shellcheck disable=SC2089
  call_cmd="ssh -o ExitOnForwardFailure=yes -o IdentitiesOnly=yes \
    -o ControlMaster=no \
    -o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=2 \
    $ssh_extra_config  $userhost -- ssh $internalhost \
    '$tail_cmd < <(cat; kill -INT 0)' <&1"

  trap 'pkill -TERM -P $$' EXIT

  max_sleep_failure=60
  last_sleep_after_failure=0
  sleep_failure=5
  while true ; do
    log "Running: $call_cmd"
    # shellcheck disable=SC2089,SC2090
    $call_cmd > "$DAEMON_RELAY"

    now="$(date +%s)"
    if [ "$now" -lt "$((last_sleep_after_failure + 10))" ]; then
      sleep_failure=$(( (sleep_failure+1) * 12 / 10 ))
      if [ "$sleep_failure" -gt "$max_sleep_failure" ]; then
        sleep_failure=$max_sleep_failure
      fi
    else
      sleep_failure=5
    fi
    log "Sleeping $sleep_failure seconds after read/ssh failure..."
    my_sleep $sleep_failure
    last_sleep_after_failure="$(date +%s)"
  done

elif [ "${FLOCKER%-client}" != "$FLOCKER" ]; then  # {{{1
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
    log "No sound file found!" >&2
  fi

  if [ -z "$DISPLAY" ]; then
    # Grab the display and xauthority cookie.
    w=$(w -h -s | grep ':[0-9]\W' | head -1 | tr -s ' ')
    DISPLAY="$(echo "$w" | cut -d\  -f2)"
    X_USER="$(echo "$w" | cut -d\  -f1)"
    XAUTHORITY="/home/$X_USER/.Xauthority"
    export DISPLAY XAUTHORITY
  fi
  if [ -z "$DISPLAY" ]; then
    log "No DISPLAY available.  Aborting." >&2
    exit 1
  fi

  log "Watching/tailing $DAEMON_RELAY.."
  ts_last_read=0
  tail -n0 -F "$DAEMON_RELAY" | while read -r date time number channel nick delim message; do
    # sed -u 's/[<@&]//g' | \

    # Ignore Twitter rebooting its service, which would re-display the last X
    # Twitter highlights again.
    ts_this_read=$(date +%s)
    if [ $(( ts_this_read - ts_last_read )) -le 5 ]; then
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

    # Sound: only once per 5 seconds, for the current DISPLAY.
    # TODO: check for focused wchat window?!
    tty="$(sed 's/^tty//' /sys/class/tty/tty0/active)"
    if [ ":$tty" = "$DISPLAY" ]; then
      if [ -n "$sound_message" ] && [ $((ts_this_read - ts_last_read)) -gt 5 ]; then
        if command -v play >/dev/null 2>&1 ; then
          log "Playing sound: $sound_message"
          # NOTE: amplified 5x to be hearable with music playing.
          # play --volume 5 -q "$sound_message" &
          play -q "$sound_message" &
        fi
      fi
    fi

    sleep_failure=5
    ts_last_read=$ts_this_read
  done
else
  log "Unexpected value for FLOCKER!" >&2
  exit 1
fi
