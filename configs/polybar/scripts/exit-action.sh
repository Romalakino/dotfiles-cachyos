#!/usr/bin/env bash
# Exit menu using rofi (CachyOS / systemd)

choice=$(echo -e "\uf023  Lock\n\uf106  Log Out\n\uf021  Reboot\n\uf011  Shutdown\n\uf186  Sleep" | rofi -dmenu -p "Exit" -theme-str 'window { width: 15%; } listview { lines: 5; }')

case "$choice" in
    *Lock) i3lock --blur 5 ;;
    *Log\ Out) i3-msg exit ;;
    *Reboot) systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
    *Sleep) systemctl suspend ;;
esac
