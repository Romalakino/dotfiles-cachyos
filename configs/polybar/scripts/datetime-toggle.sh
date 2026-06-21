#!/usr/bin/env bash
TOGGLE=/tmp/polybar-date-toggle
if [ -f "$TOGGLE" ]; then
    rm "$TOGGLE"
else
    touch "$TOGGLE"
fi
