#!/usr/bin/env bash
source ~/.config/polybar/scripts/colors.env 2>/dev/null

ICON=$'\uf017'

TOGGLE=/tmp/polybar-date-toggle
if [ -f "$TOGGLE" ]; then
    TIME=$(LANG=ru_RU.UTF-8 date +"%a %d %b")
else
    TIME=$(date +"%H:%M")
fi

echo "${ICON} ${TIME}"
