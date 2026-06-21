#!/usr/bin/env bash
CFILE=~/.config/polybar/colors.ini
get_color() {
    awk -F'= *' "/^$1 / {gsub(/[ #]/, \"\", \$2); print \$2}" "$CFILE"
}

SEC=$(get_color secondary)
FG=$(get_color foreground)
ALT=$(get_color alert)

VOL=$(pamixer --get-volume 2>/dev/null || echo 0)
MUTED=$(pamixer --get-mute 2>/dev/null || echo "false")

L=$'\ue0b6'
R=$'\ue0b7'
ICON=$'\uf028'

if [ "$MUTED" = "true" ]; then
    echo "%{F#${SEC}}${L}%{F- B#${SEC}} %{F#${ALT}}${ICON} muted %{B- F#${SEC}}${R}%{F- B-}"
else
    echo "%{F#${SEC}}${L}%{F- B#${SEC}} %{F#${FG}}${ICON} ${VOL}% %{B- F#${SEC}}${R}%{F- B-}"
fi
