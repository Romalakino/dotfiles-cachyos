#!/usr/bin/env sh
if pgrep -x polybar >/dev/null; then
    exit 0
fi
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    LANG=ru_RU.UTF-8 MONITOR=$m polybar example & disown
done
