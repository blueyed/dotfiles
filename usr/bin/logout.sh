#!/bin/sh

# slock is called via /lib/systemd/system-sleep/10lockscreen.
# TODO: via systemd user file/service?!
# Required when only suspending, e.g. closing lid!

# close stdin
exec <&-

ACTION=$(printf 'suspend|hybrid-sleep|hibernate|reboot|shutdown|switch-user|logout|lock' \
  | rofi -width -40 -dmenu -sep '|' -p "How do you want to quit? ")

if [ -n "${ACTION}" ];then
  case $ACTION in
    switch-user)
      # Lightdm: detect via XDG_SEAT_PATH
      dm-tool switch-to-greeter
      # for gdm: gdmflexiserver --startnew
      ;;
    hybrid-sleep)
      /usr/bin/slock &
      systemctl hybrid-sleep ;;
    suspend)
      /usr/bin/slock &
      systemctl suspend
      ;;
    hibernate)
      systemctl hibernate ;;
    reboot)
      zenity --question --text "Are you sure?" && systemctl reboot ;;
    shutdown)
      zenity --question --text "Are you sure?" && systemctl poweroff ;;
    logout)
      zenity --question --text "Are you sure?" && awesome-logout ;;
    lock) slock ;;
  esac
fi
