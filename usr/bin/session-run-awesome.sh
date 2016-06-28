#!/bin/bash
# Gets run via /usr/share/applications/awesome-dev.desktop.
#
# Use SIGHUP to reload awesome.
# Use SIGUSR to restart awesome.


if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0
fi

LOG=/tmp/awesome$DISPLAY.log

# POSIX compatible redirection of stdout/stderr to logfile.
stdout_pipe=$(mktemp --dry-run)
stderr_pipe=$(mktemp --dry-run)
mkfifo "$stdout_pipe"
mkfifo "$stderr_pipe"
tee -a "$LOG" < "$stdout_pipe" & exec 1> "$stdout_pipe"
tee -a "$LOG" >&2 < "$stderr_pipe" & exec 2> "$stderr_pipe"

log() {
	echo "$(date '+%F %T') $*"
}

log "== $0 =="
log "PPID:$PPID ($(ps -o args= $PPID))"

unset TERM
unset TMUX

# Make gnome-control-center display everything.
# export XDG_CURRENT_DESKTOP=GNOME
export XDG_CURRENT_DESKTOP=Unity

loop_restart=1

trap 'log "TRAPPED: USR1, restarting."; loop_restart=1; sleep_restart=0' USR1
trap 'log "TRAPPED: TERM, not restarting."; loop_restart=0' TERM

# Used for logout in awesome WM.
export MY_SESSION_RUN_PID=$$
log "MY_SESSION_RUN_PID=$MY_SESSION_RUN_PID"

cd ~
sleep_restart=1
while :; do
	log "=========== START AWESOME ==========="
	date

	loop_restart=0
	last_start="$(date +%s)"

	# Reset sleep when config file changed.
	STAT_CMD="stat -L -t $HOME/.config/awesome/rc.lua"
	last_stat="$($STAT_CMD)"

	# Read any args supplied by "awesome-restart", e.g. another config file.
	args_file="/var/run/user/$(id -u)/awesome-restart-args"
	if [ -f "$args_file" ]; then
		args="$(cat "$args_file")"
		echo "Using args: $args"
		rm "$args_file"
	else
		args=
	fi
	for f in /usr/local/bin/awesome /usr/bin/awesome; do
		if [ -x "$f" ]; then
			eval "$f $args"
			RET=$?
			echo "RET: $RET"
			if [ "$RET" = 1 ]; then
				# awesome crashed.
				loop_restart=1
			fi
			break
		fi
	done

	if ! ps $PPID 2>/dev/null 1>&2; then
		log "Parent PID ($PPID) is gone, not restarting.."
		loop_restart=0

	elif [ "$loop_restart" = 1 ]; then  # Set by 'trap'.
		# source ~/.xsessionrc
		if [ "$(expr $(date +%s) - $last_start)" -lt 2 ]; then
			if [ "$($STAT_CMD)" != "$last_stat" ]; then
				sleep_restart=0
			elif [ $(expr $sleep_restart \< 100) = 1 ]; then
				sleep_restart=$(expr $sleep_restart + 5)
			fi
		else
			sleep_restart=0
		fi

		sleep_secs=$(expr 1 + $sleep_restart / 10).$(expr $sleep_restart % 10)
		log "===== Restarting in $sleep_secs seconds. ====="
		sleep "$sleep_secs"

		if [ "$loop_restart" = 1 ]; then
			continue
		fi
	fi
	log "Breaking..."
	break
done
