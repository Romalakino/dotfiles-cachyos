---
name: cachyos-i3wm-system
description: Full system reference for this CachyOS i3wm desktop. Use when user asks about system config, keybindings, installed software, monitor setup, GPU, dotfiles structure, themes, scripts, or any setup-related question. Covers i3, polybar, picom, rofi, kitty, dunst, maim, Betterlockscreen, SDDM, AMD GPU, dual monitors, and all custom scripts.
---

# CachyOS i3wm System Reference

Complete reference of the configured CachyOS i3wm desktop environment for user **vlad**.

## System Info

| Property | Value |
|---|---|
| OS | CachyOS (Arch-based) |
| Kernel | linux-cachyos (7.x) |
| Shell | fish 4.7.1 |
| WM | i3-gaps 4.25.1 |
| Display Manager | SDDM (enabled) |
| Session | X11 (`~/.xprofile`) |
| GPU | AMD Navi 23 (RX 6650 XT) + AMD Phoenix1 (iGPU) |
| GitHub | Romalakino |
| Dotfiles | https://github.com/Romalakino/dotfiles-cachyos |

## Dual Monitor Setup

| Monitor | Resolution | Refresh Rate | Position | Role |
|---|---|---|---|---|
| DisplayPort-1 | 1920x1080 | 240Hz | Right (1440,0) | Main, workspaces 1-5 |
| HDMI-A-1-1 | 1440x900 | 60Hz | Left (0,0) | Secondary, workspaces 6-10 |

GPU config: `/etc/X11/xorg.conf.d/20-amdgpu.conf` — TearFree + VariableRefresh enabled.

## Keybindings (Super = Mod4)

### Apps
| Shortcut | Action |
|---|---|
| `Super+t` | Terminal (kitty) |
| `Super+w` | Browser (Firefox) |
| `Super+e` | File manager (Thunar) |
| `Super+c` | OpenCode Desktop |
| `Super+d` | AyuGram |
| `Super+b` | Blueman Manager |
| `Super+Shift+Return` | Terminal (alternate) |
| `Super+Shift+p` | Calculator (gnome-calculator) |

### Screenshots (maim)
| Shortcut | Action |
|---|---|
| `Print` or `Super+Shift+s` | Select area, save + clipboard |
| `Super+Print` | Full screen capture |

Screenshots saved to `~/Pictures/Screenshots/` and copied to clipboard.

### Wallpaper
| Shortcut | Action |
|---|---|
| `Super+Shift+w` | Wallpaper settings menu (Python) |

### Window Management
| Shortcut | Action |
|---|---|
| `Super+q` | Kill focused window |
| `Super+f` | Fullscreen toggle |
| `Super+Shift+space` | Floating toggle |
| `Super+space` | Focus mode toggle |
| `Super+h` | Split horizontal |
| `Super+v` | Split vertical |
| `Super+Shift+t` | Split toggle |
| `Super+s` | Layout stacking |
| `Super+Tab` | Layout tabbed |
| `Super+Shift+e` | Layout toggle split |
| `Super+a` | Focus parent |
| `Super+Arrow` | Focus direction |
| `Super+Shift+Arrow` | Move direction |
| `Super+r` | Resize mode |

### Workspaces
| Shortcut | Action |
|---|---|
| `Super+1-0` | Switch to workspace 1-10 |
| `Super+Shift+1-0` | Move window to workspace 1-10 |
| `Super+Alt+1-0` | Move + follow to workspace 1-10 |

### i3 Control
| Shortcut | Action |
|---|---|
| `Super+Shift+c` | Reload config |
| `Super+Shift+r` | Restart i3 |
| `Super+Shift+q` | Exit i3 (with confirmation) |
| `Super+l` | Lock screen (Betterlockscreen) |

### Audio
| Shortcut | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up 3% |
| `XF86AudioLowerVolume` | Volume down 3% |
| `XF86AudioMute` | Toggle mute |

Volume bar displayed via xob overlay.

### Other
| Shortcut | Action |
|---|---|
| `F12` | Toggle Rofi launcher |
| `Super+p` | PiP window (floating, sticky, 480x270) |

## Installed Software

### Core
- i3-gaps, polybar 3.7.2, picom v13, rofi 2.0, dunst 1.13.2
- kitty 0.47.1, alacritty
- Thunar (file manager), Firefox (browser)
- Betterlockscreen, xautolock, xcape
- maim + xclip + xdotool (screenshots)
- SDDM (display manager)
- Nordic GTK theme, Papirus-Dark icons
- Hack font, Font Awesome, Nerd Fonts
- fish shell, micro editor, vim

### AUR
- opencode-desktop-bin
- clash-verge-rev
- xwinwrap-git (video wallpapers)

### Python
- Pillow, numpy (wallpaper-menu.py)

## Config Locations

| Component | Config Path |
|---|---|
| i3 | `~/.config/i3/config` |
| polybar | `~/.config/polybar/config` |
| picom | `~/.config/picom/picom.conf` |
| rofi | `~/.config/rofi/config.rasi` |
| kitty | `~/.config/kitty/kitty.conf` |
| dunst | `~/.config/dunst/dunstrc` |
| GTK | `~/.config/gtk-3.0/settings.ini` |
| Qt5 | `~/.config/qt5ct/qt5ct.conf` |
| Qt6 | `~/.config/qt6ct/qt6ct.conf` |
| fish | `~/.config/fish/config.fish` |
| micro | `~/.config/micro/settings.json` |
| alacritty | `~/.config/alacritty/alacritty.toml` |
| opencode | `~/.config/opencode/opencode.jsonc` |
| Xorg keyboard | `/etc/X11/xorg.conf.d/00-keyboard.conf` |
| Xorg GPU | `/etc/X11/xorg.conf.d/20-amdgpu.conf` |
| Profile | `~/.profile`, `~/.xprofile` |

## Custom Scripts

| Script | Path | Purpose |
|---|---|---|
| screenshot.sh | `~/.config/i3/screenshot.sh` | maim-based screenshots (area/full) |
| wallpaper-menu.py | `~/.config/i3/wallpaper-menu.py` | Wallpaper picker with Nord color gen |
| restore-wallpaper.sh | `~/.config/i3/restore-wallpaper.sh` | Restore wallpaper + video wallpaper on login |
| rofi-toggle.sh | `~/.config/i3/rofi-toggle.sh` | Toggle Rofi launcher |
| polybar launch.sh | `~/.config/polybar/launch.sh` | Start/restart polybar with lang=ru_RU |
| polybar updates.sh | `~/.config/polybar/scripts/updates.sh` | Check Arch updates (checkupdates) |
| polybar arch_updates.sh | `~/.config/polybar/scripts/arch_updates.sh` | Arch update checker |
| polybar exit-action.sh | `~/.config/polybar/scripts/exit-action.sh` | Power menu (systemctl) |
| polybar datetime.sh | `~/.config/polybar/scripts/datetime.sh` | Date/time with click toggle |
| polybar volume.sh | `~/.config/polybar/scripts/volume.sh` | Volume indicator |
| polybar settings.sh | `~/.config/polybar/scripts/settings.sh` | Settings menu |
| start-i3 | `/usr/local/bin/start-i3` | i3 wrapper suppressing libi3 surface errors |

## Dotfiles Repo Structure

```
~/dotfiles-cachyos/
├── install.sh          # One-command CachyOS installer
├── backup.sh           # Backup script
├── configs/            # All dotfiles (i3, polybar, picom, kitty, etc.)
├── packages/           # Package lists (pacman, pip, manual/AUR)
├── session/            # .profile, .xprofile
├── system/             # xorg configs, sddm config
└── wallpapers/         # wallpaper.png + video wallpaper mp4
```

## Theming

- **GTK Theme**: Nordic (dark)
- **Qt Theme**: Fusion Dark via qt5ct/qt6ct
- **Icons**: Papirus-Dark
- **Cursor**: default (reset to left_ptr on startup)
- **Font**: Hack 12pt (i3), Hack (polybar, rofi)
- **Picom**: rounded corners 10px, opacity 85% for Thunar/Blueman/Pavucontrol/qt5ct/arandr, vsync, glx backend
- **Dunst**: Nord-colored notifications, timeout 5s
- **Polybar**: FontAwesome + Hack + NerdFont icons, Russian date names (ru_RU.UTF-8), Nord color scheme

## Environment Variables

Set in `~/.profile` and `~/.xprofile`:
- `EDITOR=/usr/bin/vim`
- `BROWSER=cachy-browser`
- `TERM=alacritty`
- `QT_QPA_PLATFORMTHEME=qt5ct`
- `QT_STYLE_OVERRIDE=Fusion`
- `XDG_CURRENT_DESKTOP=i3`
- `XDG_SESSION_TYPE=x11`

Also: `sudoers` grants `vlad` NOPASSWD ALL.

## Known Issues & Fixes

- **picom v13**: No animations, no round-borders options, no experimental-backends, no glx-no-stencil. Use `vsync = true` for tearing.
- **polybar 3.7.2-dev**: No tooltip support compiled in. FontAwesome name = `FontAwesome` (not `FontAwesome5Free`).
- **flameshot v14**: Requires xdg-desktop-portal (fails on i3). Replaced with `maim` + `xclip` + `xdotool`.
- **xdg-desktop-portal**: Requires `XDG_CURRENT_DESKTOP=i3` env var. Autostarted in i3 config.
- **i3 surface errors**: `libi3 ERROR: Surface not initialized` — harmless cosmetic bug from i3-gaps+picom. Suppressed via `/usr/local/bin/start-i3` wrapper.
- **Rofi rounded corners**: Excluded via `class_g = 'Rofi'` in picom config (not `window_type`).
- **Profile Sync Daemon (psd)**: Disabled — was losing Firefox session data on reboot. Firefox session restore via `user.js` (`browser.startup.page=3`).
- **Keyboard**: US+RU with Caps Lock toggle (`setxkbmap -option grp:caps_toggle "us,ru"`).
