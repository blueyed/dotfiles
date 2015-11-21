#!/bin/sh
# A wrapper around xprop to easily get class, name and other useful properties
# of windows.  Has support for awesomeWM, if awesome-client is installed.

# First get the window id.  That's not so easy with xprop.
windowid=$(xwininfo -int | sed -n '/^xwininfo: Window id: / { s/xwininfo: Window id: //; s/ .*//p }')

# Get interesting props from xprop.
xprop=$(xprop -id $windowid _NET_WM_PID WM_CLASS WM_NAME WM_WINDOW_ROLE WM_TRANSIENT_FOR _NET_WM_WINDOW_TYPE _NET_WM_STATE _NET_WM_PID)

# Get interesting props from awesome-client.
if hash awesome-client >/dev/null; then
  awesome_info=$(cat <<EOF |
    for _,c in ipairs(client.get()) do
      if c.window == $windowid then
        local r = ""
        for _,p in pairs({"border_width", "type", "border_color", "urgent",
            "window", "floating"}) do
          r = r .. p .. ": " .. tostring(c[p]) .. "\n"
        end
        return "\n" .. r .. "\n"
      end
    end
EOF
awesome-client | sed '1d; $d')
fi

zenity --info --no-markup --text "$xprop
$awesome_info"
