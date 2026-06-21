#!/usr/bin/env bash
if pgrep -x rofi >/dev/null; then
    killall rofi
else
    rofi -show drun
fi
