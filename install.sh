#!/usr/bin/env bash
# install.sh — i3wm Desktop Environment Installer for CachyOS / Arch Linux
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[x]${NC} $*"; }
info() { echo -e "${CYAN}[~]${NC} $*"; }

if [ "$EUID" -eq 0 ]; then
    err "Do not run this script as root. It will ask for sudo when needed."
    exit 1
fi

if [ ! -f /etc/os-release ] || ! grep -qiE "arch|cachyos" /etc/os-release 2>/dev/null; then
    warn "This doesn't look like Arch/CachyOS. Proceed anyway? (y/N)"
    read -r answer
    [ "$answer" = "y" ] || exit 1
fi

echo ""
echo "========================================="
echo "  i3wm Desktop Environment Installer"
echo "  Target: CachyOS / Arch Linux"
echo "========================================="
echo ""

# ==========================================
# Phase 1: System setup
# ==========================================
log "Phase 1: System setup..."

if ! command -v pacman &>/dev/null; then
    err "pacman not found. This script requires Arch Linux or derivative."
    exit 1
fi

log "Updating system..."
sudo pacman -Syu --noconfirm

# ==========================================
# Phase 2: Install packages
# ==========================================
log "Phase 2: Installing packages..."

PACKAGES=(
    # Core WM
    i3-gaps i3lock i3blocks i3status
    polybar picom rofi dunst
    betterlockscreen xautolock xcape

    # Terminal
    kitty alacritty

    # File Manager
    thunar thunar-volman

    # Wallpaper & Display
    feh mpv ffmpeg arandr

    # Screenshots
    maim xclip xdotool

    # Audio
    pamixer pavucontrol

    # Display Manager
    sddm

    # Bluetooth & Devices
    blueman udiskie

    # Theming
    qt5ct qt6ct

    # Network
    networkmanager network-manager-applet

    # Fonts
    ttf-hack ttf-font-awesome

    # Python
    python-pip

    # System
    polkit-gnome dex dbus

    # Xorg
    xorg-server xorg-xinit

    # Update checker (for polybar)
    pacman-contrib

    # Misc
    jq
)

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        info "  $pkg already installed"
    else
        log "  Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg" 2>/dev/null || warn "  Failed to install $pkg (may not be in repos)"
    fi
done

# Install yay/AUR packages if available
if command -v yay &>/dev/null; then
    log "  Installing AUR packages..."
    AUR_PACKAGES=(betterlockscreen)
    for pkg in "${AUR_PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            info "  $pkg already installed"
        else
            yay -S --noconfirm --answerdiff None --answerclean None --removemake "$pkg" 2>/dev/null || warn "  Failed to install $pkg from AUR"
        fi
    done
fi

# ==========================================
# Phase 3: Python dependencies
# ==========================================
log "Phase 3: Installing Python dependencies..."
pip install --user --break-system-packages Pillow numpy 2>/dev/null || pip3 install --user --break-system-packages Pillow numpy 2>/dev/null || python -m pip install --user --break-system-packages Pillow numpy 2>/dev/null || python3 -m pip install --user --break-system-packages Pillow numpy 2>/dev/null || warn "pip install failed, install Pillow and numpy manually"

# ==========================================
# Phase 4: Install xwinwrap (for video wallpapers)
# ==========================================
log "Phase 4: Installing xwinwrap..."
if command -v xwinwrap &>/dev/null; then
    info "xwinwrap already installed"
else
    if command -v yay &>/dev/null; then
        if yay -S --noconfirm --answerdiff None --answerclean None --removemake xwinwrap-git 2>/dev/null; then
            log "xwinwrap installed from AUR"
        else
            warn "Failed to install xwinwrap from AUR, skipping"
        fi
    else
        info "Building xwinwrap from source..."
        TEMP_DIR=$(mktemp -d)
        (
            cd "$TEMP_DIR"
            git clone https://github.com/adi1090x/xwinwrap.git 2>/dev/null || git clone https://github.com/stefanct/xwinwrap.git 2>/dev/null || { warn "Failed to clone xwinwrap"; exit 1; }
            cd xwinwrap
            make
            sudo make install
        )
        rm -rf "$TEMP_DIR"
        log "xwinwrap installed"
    fi
fi

# ==========================================
# Phase 5: Install sddm-sugar-candy theme
# ==========================================
log "Phase 5: Installing SDDM sugar-candy theme..."
if [ -d /usr/share/sddm/themes/sugar-candy ]; then
    info "sugar-candy theme already installed"
else
    if yay -S --noconfirm --answerdiff None --answerclean None --removemake sddm-sugar-candy-theme 2>/dev/null; then
        log "sugar-candy theme installed from AUR"
    else
        TEMP_DIR=$(mktemp -d)
        (
            cd "$TEMP_DIR"
            wget -q "https://github.com/Kangie/sddm-sugar-candy/archive/refs/heads/main.tar.gz" -O sugar-candy.tar.gz || \
            wget -q "https://github.com/Kangie/sddm-sugar-candy/releases/latest/download/sugar-candy.tar.gz" -O sugar-candy.tar.gz || \
            { warn "Failed to download sugar-candy theme"; exit 1; }
            sudo mkdir -p /usr/share/sddm/themes
            sudo tar -xzf sugar-candy.tar.gz -C /usr/share/sddm/themes/
            [ -d /usr/share/sddm/themes/sddm-sugar-candy-main ] && sudo mv /usr/share/sddm/themes/sddm-sugar-candy-main /usr/share/sddm/themes/sugar-candy
        )
        rm -rf "$TEMP_DIR"
        log "sugar-candy theme installed"
    fi
fi

# ==========================================
# Phase 6: Install Nordic GTK theme
# ==========================================
log "Phase 6: Installing Nordic GTK theme..."
if [ -d "$HOME/.themes/Nordic" ]; then
    info "Nordic theme already installed"
else
    mkdir -p "$HOME/.themes"
    git clone https://github.com/EliverLara/Nordic.git "$HOME/.themes/Nordic" 2>/dev/null || warn "Failed to clone Nordic theme"
    log "Nordic theme installed"
fi

# ==========================================
# Phase 7: Deploy configs
# ==========================================
log "Phase 7: Deploying configuration files..."

deploy() {
    local src="$1" dst="$2"
    if [ -e "$dst" ]; then
        warn "  Backing up existing: $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    cp -r "$src" "$dst"
    info "  Deployed: $dst"
}

# i3 configs
mkdir -p "$HOME/.config/i3"
for f in "$SCRIPT_DIR/configs/i3/"*; do
    fname=$(basename "$f")
    deploy "$f" "$HOME/.config/i3/$fname"
done

# polybar configs
mkdir -p "$HOME/.config/polybar/scripts"
for f in "$SCRIPT_DIR/configs/polybar/"*; do
    fname=$(basename "$f")
    if [ -d "$f" ]; then
        for s in "$f/"*; do
            sname=$(basename "$s")
            deploy "$s" "$HOME/.config/polybar/$fname/$sname"
        done
    else
        deploy "$f" "$HOME/.config/polybar/$fname"
    fi
done

# picom
mkdir -p "$HOME/.config/picom"
deploy "$SCRIPT_DIR/configs/picom/picom.conf" "$HOME/.config/picom/picom.conf"

# kitty
mkdir -p "$HOME/.config/kitty"
deploy "$SCRIPT_DIR/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
deploy "$SCRIPT_DIR/configs/kitty/colors.conf" "$HOME/.config/kitty/colors.conf"

# alacritty
mkdir -p "$HOME/.config/alacritty"
deploy "$SCRIPT_DIR/configs/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
deploy "$SCRIPT_DIR/configs/alacritty/colors.toml" "$HOME/.config/alacritty/colors.toml"

# rofi
mkdir -p "$HOME/.config/rofi"
deploy "$SCRIPT_DIR/configs/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
deploy "$SCRIPT_DIR/configs/rofi/colors.rasi" "$HOME/.config/rofi/colors.rasi"

# dunst
mkdir -p "$HOME/.config/dunst"
deploy "$SCRIPT_DIR/configs/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"

# betterlockscreen
mkdir -p "$HOME/.config/betterlockscreen"
deploy "$SCRIPT_DIR/configs/betterlockscreen/betterlockscreenrc" "$HOME/.config/betterlockscreen/betterlockscreenrc"

# gtk
mkdir -p "$HOME/.config/gtk-3.0"
deploy "$SCRIPT_DIR/configs/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
deploy "$SCRIPT_DIR/configs/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
deploy "$SCRIPT_DIR/configs/gtk-3.0/bookmarks" "$HOME/.config/gtk-3.0/bookmarks"
deploy "$SCRIPT_DIR/configs/.gtkrc-2.0" "$HOME/.gtkrc-2.0"

# qt
mkdir -p "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"
deploy "$SCRIPT_DIR/configs/qt5ct/qt5ct.conf" "$HOME/.config/qt5ct/qt5ct.conf"
deploy "$SCRIPT_DIR/configs/qt6ct/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"

# fish
mkdir -p "$HOME/.config/fish"
deploy "$SCRIPT_DIR/configs/fish/config.fish" "$HOME/.config/fish/config.fish"

# micro
mkdir -p "$HOME/.config/micro"
deploy "$SCRIPT_DIR/configs/micro/settings.json" "$HOME/.config/micro/settings.json"

# opencode
mkdir -p "$HOME/.config/opencode"
deploy "$SCRIPT_DIR/configs/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
# opencode skills
if [ -d "$SCRIPT_DIR/configs/opencode/skills" ]; then
    mkdir -p "$HOME/.config/opencode/skills"
    cp -r "$SCRIPT_DIR/configs/opencode/skills/"* "$HOME/.config/opencode/skills/" 2>/dev/null || true
    info "  OpenCode skills deployed"
fi

# Session files
deploy "$SCRIPT_DIR/session/.profile" "$HOME/.profile"
deploy "$SCRIPT_DIR/session/.xprofile" "$HOME/.xprofile"
chmod +x "$HOME/.xprofile" 2>/dev/null || true

# Wallpapers
mkdir -p "$HOME/Pictures/Wallpapers"
for f in "$SCRIPT_DIR/wallpapers/"*; do
    [ -f "$f" ] && cp "$f" "$HOME/Pictures/Wallpapers/"
done
info "Wallpapers deployed"

# ==========================================
# Phase 8: System configs (need sudo)
# ==========================================
log "Phase 8: Deploying system configs..."

# X11 keyboard + mouse + GPU
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp "$SCRIPT_DIR/system/xorg/00-keyboard.conf" /etc/X11/xorg.conf.d/
sudo cp "$SCRIPT_DIR/system/xorg/01-mouse.conf" /etc/X11/xorg.conf.d/
if [ -f "$SCRIPT_DIR/system/xorg/20-amdgpu.conf" ]; then
    sudo cp "$SCRIPT_DIR/system/xorg/20-amdgpu.conf" /etc/X11/xorg.conf.d/
    info "AMD GPU config deployed (TearFree + VariableRefresh)"
fi
info "X11 input configs deployed"

# i3 wrapper to suppress libi3 surface errors
sudo tee /usr/local/bin/start-i3 >/dev/null << 'WRAPPER'
#!/bin/bash
exec i3 2>/dev/null
WRAPPER
sudo chmod +x /usr/local/bin/start-i3
sudo sed -i 's|^Exec=i3|Exec=/usr/local/bin/start-i3|' /usr/share/xsessions/i3.desktop 2>/dev/null || true
info "i3 wrapper deployed (suppresses surface errors)"

# SDDM config
sudo mkdir -p /etc/sddm.conf.d
sudo cp "$SCRIPT_DIR/system/sddm.conf" /etc/sddm.conf.d/theme.conf
info "SDDM config deployed"

# SDDM theme config (if theme exists)
if [ -d /usr/share/sddm/themes/sugar-candy ]; then
    sudo cp "$SCRIPT_DIR/system/sddm-theme/theme.conf" /usr/share/sddm/themes/sugar-candy/theme.conf 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/wallpapers/wallpaper.png" ]; then
        sudo cp "$SCRIPT_DIR/wallpapers/wallpaper.png" /usr/share/sddm/themes/sugar-candy/Backgrounds/login.png 2>/dev/null || true
    fi
    info "SDDM theme config deployed"
fi

# ==========================================
# Phase 9: Enable services (systemd)
# ==========================================
log "Phase 9: Enabling services..."

enable_service() {
    local svc="$1"
    if systemctl list-unit-files "${svc}.service" &>/dev/null; then
        if systemctl is-enabled "$svc" &>/dev/null; then
            info "  $svc already enabled"
        else
            sudo systemctl enable "$svc"
            log "  Enabled: $svc"
        fi
    else
        warn "  Service not found: $svc"
    fi
}

enable_service sddm
enable_service NetworkManager
enable_service bluetooth

# ==========================================
# Phase 10: Make scripts executable
# ==========================================
log "Phase 10: Setting permissions..."
chmod +x "$HOME/.config/i3/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/polybar/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/i3/wallpaper-menu.py" 2>/dev/null || true

# ==========================================
# Phase 11: Generate lock screen cache
# ==========================================
log "Phase 11: Generating betterlockscreen cache..."
if [ -f "$HOME/.config/i3/wallpaper.png" ]; then
    betterlockscreen -u "$HOME/.config/i3/wallpaper.png" --fx dim,blur --dim 10 --blur 0.05 2>/dev/null || warn "betterlockscreen cache generation failed (run manually later)"
fi

# ==========================================
# Phase 12: Set keyboard layout
# ==========================================
log "Phase 12: Setting keyboard layout..."
setxkbmap -option grp:caps_toggle "us,ru" -option "grp:caps_toggle,grp_led:caps" 2>/dev/null || true

# ==========================================
# Done
# ==========================================
echo ""
echo "========================================="
echo -e "${GREEN}  Installation complete!${NC}"
echo "========================================="
echo ""
echo "  What was installed:"
echo "    - i3-gaps window manager"
echo "    - polybar status bar"
echo "    - picom compositor"
echo "    - rofi launcher"
echo "    - dunst notifications"
echo "    - kitty + alacritty terminals"
echo "    - betterlockscreen"
echo "    - sddm with sugar-candy theme"
echo "    - Nordic GTK theme"
echo "    - All configs deployed"
echo ""
echo "  Next steps:"
echo "    1. Reboot: sudo reboot"
echo "    2. After login, run: ~/.config/i3/wallpaper-menu.py"
echo "       to apply wallpaper colors to all configs"
echo "    3. If picom dual_kawase blur doesn't work,"
echo "       compile the ibhagwan/picom fork"
echo ""
echo "  To restore video wallpapers:"
echo "    - Place .mp4 files in ~/Pictures/Wallpapers/"
echo "    - Use Super+Shift+W -> Wallpaper (Video)"
echo ""
