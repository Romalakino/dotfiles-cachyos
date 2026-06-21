#!/usr/bin/env bash
# Restore wallpaper from saved state on i3 startup

CW=~/.config/i3/current-wallpaper

if [ ! -f "$CW" ]; then
    feh --bg-fill ~/.config/i3/wallpaper.png 2>/dev/null
    exit 0
fi

line=$(head -1 "$CW")

if [[ "$line" == video:* ]]; then
    path=$(echo "$line" | sed 's/^video://; s/:[0-9]*$//')
    if [ -f "$path" ]; then
        killall xwinwrap 2>/dev/null
        killall mpv 2>/dev/null
        sleep 0.3
        xwinwrap -g 3360x1080+0+0 -ov -ni -s -st -sp -b -nf -d -- mpv -wid %WID --loop --no-audio --no-osc --no-input-default-bindings --really-quiet --panscan=1.0 "$path" &
        disown
    else
        feh --bg-fill ~/.config/i3/wallpaper.png 2>/dev/null
    fi
elif [[ "$line" == static:* ]]; then
    path=$(echo "$line" | sed 's/^static://')
    if [ -f "$path" ]; then
        feh --bg-fill "$path" 2>/dev/null
    else
        feh --bg-fill ~/.config/i3/wallpaper.png 2>/dev/null
    fi
else
    feh --bg-fill ~/.config/i3/wallpaper.png 2>/dev/null
fi
