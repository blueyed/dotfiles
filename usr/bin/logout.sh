#!/bin/sh

# close stdin
exec <&-

ACTION=$(printf 'suspend|hybrid-sleep|hibernate|reboot|shutdown|switch-user|logout|lock' \
  | rofi -dmenu -sep '|' -p "How do you want to quit? ")

if [ -n "${ACTION}" ];then
  case $ACTION in
    switch-user)
      # Lightdm: detect via XDG_SEAT_PATH
      dm-tool switch-to-greeter
      # for gdm: gdmflexiserver --startnew
      ;;
    hybrid-sleep) systemctl hybrid-sleep ;;
    suspend)
      systemctl suspend
      /usr/bin/slock
      ;;
    hibernate)    systemctl hibernate ;;
    reboot)
      zenity --question --text "Are you sure?" \
        && systemctl reboot ;;
    shutdown)
      zenity --question --text "Are you sure?" \
        && systemctl poweroff ;;
    logout)
      zenity --question --text "Are you sure?" \
        && gnome-session-quit --logout --no-prompt ;;
    lock) slock ;;
  esac
fi
