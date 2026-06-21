# i3wm Dotfiles

Personal i3wm desktop environment configs for Void Linux.

## What's Included

| Component | Details |
|-----------|---------|
| **WM** | i3-gaps with custom gaps and keybindings |
| **Bar** | Polybar (bubble style, pseudo-transparency) |
| **Compositor** | Picom (dual_kawase blur, rounded corners, animations) |
| **Launcher** | Rofi (drun toggle + combi) |
| **Lock** | betterlockscreen (i3lock-color) |
| **Notifications** | dunst |
| **Terminals** | kitty + alacritty |
| **Login** | SDDM with sugar-candy theme |
| **Theme Engine** | wallpaper-menu.py (K-means color extraction) |

## Quick Install (Void Linux)

```bash
git clone https://github.com/YOUR_USER/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

## Manual Backup (CachyOS/Arch)

```bash
chmod +x backup.sh
./backup.sh
```

## Keybindings

| Key | Action |
|-----|--------|
| Super+T | Terminal (kitty) |
| Super+W | Browser (firefox) |
| Super+E | Files (thunar) |
| Super+Q | Kill window |
| Super+C | opencode |
| Super+L | Lock screen |
| Super+Shift+W | Settings / Wallpaper menu |
| Super+Shift+S | Screenshot (flameshot) |
| Super (alone) | Rofi launcher |
| Ctrl+Space | Rofi combi |
| Print | Screenshot |

## Wallpaper System

wallpaper-menu.py is the central theme engine:
- Extracts colors from wallpapers via K-means clustering
- Applies colors to all configs (i3, polybar, kitty, alacritty, rofi, gtk, qt, betterlockscreen)
- Supports static wallpapers (feh) and video wallpapers (xwinwrap + mpv)
- Run with: `python3 ~/.config/i3/wallpaper-menu.py` or Super+Shift+W

## Adapting for Other Distros

The configs are mostly distro-independent. Main changes needed:

1. **exit-action.sh**: Replace `sudo reboot`/`sudo shutdown`/`sudo zzz` with your init system's commands
2. **updates.sh**: Replace `xbps-install -Simup` with your package manager's update check
3. **.profile**: Change `BROWSER=firefox` to your preferred browser
4. **GTK theme**: Change `Nordic` to your installed theme name
5. **i3 config**: Adjust `set $browser` and `set $term` as needed

## Dependencies

See `packages/xbps.list` for the full package list. Key dependencies:

- Python 3 + Pillow + NumPy (for wallpaper-menu.py)
- xwinwrap (compiled from source, for video wallpapers)
- ttf-hack font
- betterlockscreen + i3lock

## File Structure

```
dotfiles/
├── install.sh          # Void Linux installer
├── backup.sh           # CachyOS backup script
├── packages/           # Package lists
├── configs/            # All dotfiles
│   ├── i3/
│   ├── polybar/
│   ├── picom/
│   ├── kitty/
│   ├── alacritty/
│   ├── rofi/
│   ├── dunst/
│   ├── betterlockscreen/
│   ├── gtk-3.0/
│   ├── qt5ct/
│   └── qt6ct/
├── session/            # .xsession, .xinitrc, .profile
├── system/             # /etc configs (xorg, sddm)
└── wallpapers/         # Wallpaper images + videos
```
