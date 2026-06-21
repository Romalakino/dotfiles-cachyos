#!/usr/bin/env bash
# backup.sh — Run on CachyOS to back up all i3wm configs
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

echo "=== i3wm Dotfiles Backup ==="
echo "Backing up from: $HOME_DIR"
echo "To: $SCRIPT_DIR"
echo ""

# --- i3 ---
echo "[1/12] Backing up i3 configs..."
mkdir -p "$SCRIPT_DIR/configs/i3"
cp "$HOME_DIR/.config/i3/config" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/colors" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/wallpaper-menu.py" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/restore-wallpaper.sh" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/rofi-toggle.sh" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/current-wallpaper" "$SCRIPT_DIR/configs/i3/"
cp "$HOME_DIR/.config/i3/idle-enabled" "$SCRIPT_DIR/configs/i3/" 2>/dev/null || true
cp "$HOME_DIR/.config/i3/wallpaper.png" "$SCRIPT_DIR/configs/i3/"

# --- polybar ---
echo "[2/12] Backing up polybar configs..."
mkdir -p "$SCRIPT_DIR/configs/polybar/scripts"
cp "$HOME_DIR/.config/polybar/config" "$SCRIPT_DIR/configs/polybar/"
cp "$HOME_DIR/.config/polybar/colors.ini" "$SCRIPT_DIR/configs/polybar/"
cp "$HOME_DIR/.config/polybar/launch.sh" "$SCRIPT_DIR/configs/polybar/"
cp "$HOME_DIR/.config/polybar/scripts/"*.sh "$SCRIPT_DIR/configs/polybar/scripts/"
cp "$HOME_DIR/.config/polybar/scripts/colors.env" "$SCRIPT_DIR/configs/polybar/scripts/"

# --- picom ---
echo "[3/12] Backing up picom config..."
mkdir -p "$SCRIPT_DIR/configs/picom"
cp "$HOME_DIR/.config/picom/picom.conf" "$SCRIPT_DIR/configs/picom/"

# --- kitty ---
echo "[4/12] Backing up kitty config..."
mkdir -p "$SCRIPT_DIR/configs/kitty"
cp "$HOME_DIR/.config/kitty/kitty.conf" "$SCRIPT_DIR/configs/kitty/"
cp "$HOME_DIR/.config/kitty/colors.conf" "$SCRIPT_DIR/configs/kitty/"

# --- alacritty ---
echo "[5/12] Backing up alacritty config..."
mkdir -p "$SCRIPT_DIR/configs/alacritty"
cp "$HOME_DIR/.config/alacritty/alacritty.toml" "$SCRIPT_DIR/configs/alacritty/"
cp "$HOME_DIR/.config/alacritty/colors.toml" "$SCRIPT_DIR/configs/alacritty/"

# --- rofi ---
echo "[6/12] Backing up rofi config..."
mkdir -p "$SCRIPT_DIR/configs/rofi"
cp "$HOME_DIR/.config/rofi/config.rasi" "$SCRIPT_DIR/configs/rofi/"
cp "$HOME_DIR/.config/rofi/colors.rasi" "$SCRIPT_DIR/configs/rofi/"

# --- dunst ---
echo "[7/12] Backing up dunst config..."
mkdir -p "$SCRIPT_DIR/configs/dunst"
cp "$HOME_DIR/.config/dunst/dunstrc" "$SCRIPT_DIR/configs/dunst/"

# --- betterlockscreen ---
echo "[8/12] Backing up betterlockscreen config..."
mkdir -p "$SCRIPT_DIR/configs/betterlockscreen"
cp "$HOME_DIR/.config/betterlockscreen/betterlockscreenrc" "$SCRIPT_DIR/configs/betterlockscreen/"

# --- gtk, qt ---
echo "[9/12] Backing up GTK/Qt configs..."
mkdir -p "$SCRIPT_DIR/configs/gtk-3.0"
cp "$HOME_DIR/.config/gtk-3.0/settings.ini" "$SCRIPT_DIR/configs/gtk-3.0/"
cp "$HOME_DIR/.config/gtk-3.0/gtk.css" "$SCRIPT_DIR/configs/gtk-3.0/"
cp "$HOME_DIR/.config/gtk-3.0/bookmarks" "$SCRIPT_DIR/configs/gtk-3.0/"
cp "$HOME_DIR/.gtkrc-2.0" "$SCRIPT_DIR/configs/"
mkdir -p "$SCRIPT_DIR/configs/qt5ct"
cp "$HOME_DIR/.config/qt5ct/qt5ct.conf" "$SCRIPT_DIR/configs/qt5ct/"
mkdir -p "$SCRIPT_DIR/configs/qt6ct"
cp "$HOME_DIR/.config/qt6ct/qt6ct.conf" "$SCRIPT_DIR/configs/qt6ct/"

# --- fish ---
mkdir -p "$SCRIPT_DIR/configs/fish"
cp "$HOME_DIR/.config/fish/config.fish" "$SCRIPT_DIR/configs/fish/"

# --- micro ---
mkdir -p "$SCRIPT_DIR/configs/micro"
cp "$HOME_DIR/.config/micro/settings.json" "$SCRIPT_DIR/configs/micro/"

# --- opencode ---
mkdir -p "$SCRIPT_DIR/configs/opencode"
cp "$HOME_DIR/.config/opencode/opencode.jsonc" "$SCRIPT_DIR/configs/opencode/"

# --- session files ---
echo "[10/12] Backing up session files..."
mkdir -p "$SCRIPT_DIR/session"
cp "$HOME_DIR/.xsession" "$SCRIPT_DIR/session/"
cp "$HOME_DIR/.xinitrc" "$SCRIPT_DIR/session/"
cp "$HOME_DIR/.profile" "$SCRIPT_DIR/session/"

# --- system files (need sudo) ---
echo "[11/12] Backing up system files..."
mkdir -p "$SCRIPT_DIR/system/xorg"
sudo cp /etc/X11/xorg.conf.d/00-keyboard.conf "$SCRIPT_DIR/system/xorg/"
sudo cp /etc/X11/xorg.conf.d/01-mouse.conf "$SCRIPT_DIR/system/xorg/"
mkdir -p "$SCRIPT_DIR/system"
sudo cp /etc/sddm.conf.d/theme.conf "$SCRIPT_DIR/system/sddm.conf"

# --- wallpapers ---
echo "[12/12] Backing up wallpapers..."
mkdir -p "$SCRIPT_DIR/wallpapers"
cp "$HOME_DIR/.config/i3/wallpaper.png" "$SCRIPT_DIR/wallpapers/"
# Copy all wallpapers (including video)
if [ -d "$HOME_DIR/Pictures/Wallpapers" ]; then
    cp -r "$HOME_DIR/Pictures/Wallpapers/"* "$SCRIPT_DIR/wallpapers/" 2>/dev/null || true
fi

# --- generate package lists ---
echo ""
echo "Generating package lists..."

# Python packages
pip list --format=freeze 2>/dev/null | grep -iE "^(pillow|numpy)" > "$SCRIPT_DIR/packages/pip.list" || true

echo ""
echo "=== Backup complete! ==="
echo "Review files in: $SCRIPT_DIR"
echo "Then: cd $SCRIPT_DIR && git init && git add -A && git commit -m 'i3wm dotfiles'"
echo "And: git remote add origin <your-github-url> && git push -u origin main"
