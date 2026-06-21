#!/bin/bash
mkdir -p ~/Pictures/Screenshots
file=~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png

case "$1" in
    area)
        maim -s -u "$file" && xclip -selection clipboard -t image/png -i "$file" && notify-send "Screenshot" "Saved to $file"
        ;;
    full)
        maim "$file" && xclip -selection clipboard -t image/png -i "$file" && notify-send "Screenshot" "Full screen saved to $file"
        ;;
    *)
        maim -s -u "$file" && xclip -selection clipboard -t image/png -i "$file" && notify-send "Screenshot" "Saved to $file"
        ;;
esac
