#!/usr/bin/env python3
import os
import subprocess
from PIL import Image
import numpy as np

WALLPAPER_DIR = os.path.expanduser("~/Pictures/Wallpapers")
CURRENT_WALL = os.path.expanduser("~/.config/i3/current-wallpaper")
COLORS_FILE = os.path.expanduser("~/.config/i3/colors")
POLYBAR_COLORS = os.path.expanduser("~/.config/polybar/colors.ini")
ALACRITTY_COLORS = os.path.expanduser("~/.config/alacritty/colors.toml")
KITTY_COLORS = os.path.expanduser("~/.config/kitty/colors.conf")
ROFI_COLORS = os.path.expanduser("~/.config/rofi/colors.rasi")
VIDEO_EXTENSIONS = {'.mp4', '.webm', '.mkv', '.avi', '.mov', '.gif'}
IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.bmp', '.webp', '.tiff'}

DEFAULT_COLORS = {
    'bg': '#1e1e2e', 'bg_alt': '#181825', 'fg': '#cdd6f4', 'fg_alt': '#bac2de',
    'primary': '#89b4fa', 'secondary': '#f5c2e7', 'error': '#f38ba8',
    'surface': '#313244', 'surface_alt': '#242438', 'outline': '#585b70',
    'accent': '#74c7ec'
}

def extract_colors(image_path, n_colors=8):
    img = Image.open(image_path).convert('RGB')
    img = img.resize((150, 150), Image.Resampling.LANCZOS)
    pixels = np.array(img).reshape(-1, 3).astype(float)
    centroids = pixels[np.random.choice(len(pixels), n_colors, replace=False)]
    for _ in range(20):
        dists = np.linalg.norm(pixels[:, None] - centroids[None, :], axis=2)
        labels = np.argmin(dists, axis=1)
        new_centroids = np.array([pixels[labels == i].mean(axis=0) if np.any(labels == i) else centroids[i] for i in range(n_colors)])
        if np.allclose(centroids, new_centroids, atol=1):
            break
        centroids = new_centroids
    counts = np.bincount(labels, minlength=n_colors)
    order = np.argsort(-counts)
    centroids = centroids[order].astype(int)

    def brightness(c):
        return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]

    dark_idx = [i for i in range(n_colors) if brightness(centroids[i]) < 128]
    light_idx = [i for i in range(n_colors) if brightness(centroids[i]) >= 128]
    if not dark_idx:
        dark_idx = list(range(n_colors))
    if not light_idx:
        light_idx = list(range(n_colors))
    c = centroids
    bg = c[dark_idx[0]]
    bg_alt = c[dark_idx[min(1, len(dark_idx) - 1)]]
    fg = c[light_idx[0]]
    fg_alt = c[light_idx[min(1, len(light_idx) - 1)]]
    accent_candidates = [c[i] for i in range(n_colors)
                         if i not in [dark_idx[0], light_idx[0]]
                         and abs(brightness(c[i]) - 128) < 80]
    if not accent_candidates:
        accent_candidates = [c[i] for i in range(1, n_colors)]
    accent = accent_candidates[0]
    accent_alt = accent_candidates[min(1, len(accent_candidates) - 1)]
    error = np.clip(accent + np.array([120, -60, -60]), 0, 255).astype(int)
    return {
        'bg': rgb_hex(bg), 'bg_alt': rgb_hex(bg_alt),
        'fg': rgb_hex(fg), 'fg_alt': rgb_hex(fg_alt),
        'primary': rgb_hex(accent), 'secondary': rgb_hex(accent_alt),
        'error': rgb_hex(error),
        'surface': rgb_hex(np.clip((bg * 0.7 + fg * 0.3), 0, 255).astype(int)),
        'surface_alt': rgb_hex(np.clip((bg * 0.85 + fg * 0.15), 0, 255).astype(int)),
        'outline': rgb_hex(np.clip((bg * 0.5 + fg * 0.5), 0, 255).astype(int)),
        'accent': rgb_hex(np.clip((accent * 0.8 + fg * 0.2), 0, 255).astype(int)),
    }

def rgb_hex(c):
    return f"#{c[0]:02x}{c[1]:02x}{c[2]:02x}"

def hex_to_0x(h):
    return f"0x{h[1:]}"

def set_static_wallpaper(path):
    subprocess.run(["feh", "--bg-fill", path], check=True)
    with open(CURRENT_WALL, 'w') as f:
        f.write(f"static:{path}\n")

def set_video_wallpaper(path):
    kill_video_wallpaper()
    subprocess.Popen([
        "xwinwrap", "-g", "3360x1080+0+0", "-ov", "-ni", "-s", "-st", "-sp", "-b", "-nf", "-d",
        "--", "mpv", "-wid", "%WID", "--loop", "--no-audio", "--no-osc",
        "--no-input-default-bindings", "--really-quiet", "--panscan=1.0", path
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def kill_video_wallpaper():
    if os.path.exists(CURRENT_WALL):
        with open(CURRENT_WALL) as f:
            line = f.readline().strip()
            if line.startswith("video:"):
                parts = line.split(":")
                if len(parts) >= 3:
                    try:
                        os.kill(int(parts[2]), 9)
                    except (ProcessLookupError, ValueError):
                        pass
    subprocess.run(["pkill", "-f", "xwinwrap"], stderr=subprocess.DEVNULL)

def extract_first_frame(video_path):
    frame_path = "/tmp/wallpaper-frame.png"
    subprocess.run(["ffmpeg", "-y", "-i", video_path, "-vframes", "1", frame_path], capture_output=True)
    return frame_path

def apply_colors(colors):
    with open(COLORS_FILE, 'w') as f:
        f.write(f"client.focused          {colors['bg_alt']} {colors['bg_alt']} {colors['fg']} {colors['primary']}   {colors['primary']}\n")
        f.write(f"client.focused_inactive {colors['surface']} {colors['surface']} {colors['fg_alt']} {colors['outline']}   {colors['outline']}\n")
        f.write(f"client.unfocused        {colors['surface_alt']} {colors['surface_alt']} {colors['fg_alt']} {colors['outline']}   {colors['outline']}\n")
        f.write(f"client.urgent           {colors['error']} {colors['error']} {colors['fg']} {colors['error']}   {colors['error']}\n")
        f.write(f"client.placeholder      {colors['bg']} {colors['bg']} {colors['fg']} {colors['outline']}   {colors['outline']}\n")
        f.write(f"client.background       {colors['bg']}\n")

    name_map = {
        'bg_alt': 'background-alt', 'fg': 'foreground', 'fg_alt': 'foreground-alt',
        'error': 'alert', 'surface_alt': 'surface-alt'
    }
    with open(POLYBAR_COLORS, 'w') as f:
        f.write("[colors]\n")
        f.write("background = #00000000\n")
        for k in ['bg_alt', 'fg', 'fg_alt', 'primary', 'secondary', 'error', 'surface', 'surface_alt', 'outline', 'accent']:
            ini_key = name_map.get(k, k).replace('_', '-')
            f.write(f"{ini_key} = {colors[k]}\n")

    SCRIPT_COLORS = os.path.expanduser("~/.config/polybar/scripts/colors.env")
    with open(SCRIPT_COLORS, 'w') as f:
        f.write("#!/usr/bin/env bash\n")
        f.write("# Color cache for polybar scripts\n")
        f.write("# Auto-generated by wallpaper-menu.py\n\n")
        f.write(f'SECONDARY="{colors["secondary"].lstrip("#")}"\n')
        f.write(f'FG="{colors["fg"].lstrip("#")}"\n')
        f.write(f'ALT="{colors["error"].lstrip("#")}"\n')
        f.write(f'SURFACE="{colors["surface"].lstrip("#")}"\n')
        f.write(f'FG_ALT="{colors["fg_alt"].lstrip("#")}"\n')
        f.write(f'ACCENT="{colors["primary"].lstrip("#")}"\n')
        f.write(f'PRIMARY="{colors["primary"].lstrip("#")}"\n')

    with open(ALACRITTY_COLORS, 'w') as f:
        f.write('[colors]\n')
        f.write('draw_bold_text_with_bright_colors = true\n\n')
        f.write('[colors.primary]\n')
        f.write(f'background = "{hex_to_0x(colors["bg"])}"\n')
        f.write(f'foreground = "{hex_to_0x(colors["fg"])}"\n\n')
        f.write('[colors.normal]\n')
        f.write(f'black = "{hex_to_0x(colors["bg_alt"])}"\n')
        f.write(f'red = "{hex_to_0x(colors["error"])}"\n')
        f.write(f'green = "{hex_to_0x(colors["secondary"])}"\n')
        f.write(f'yellow = "{hex_to_0x(colors["primary"])}"\n')
        f.write(f'blue = "{hex_to_0x(colors["primary"])}"\n')
        f.write(f'magenta = "{hex_to_0x(colors["secondary"])}"\n')
        f.write(f'cyan = "{hex_to_0x(colors["fg_alt"])}"\n')
        f.write(f'white = "{hex_to_0x(colors["fg"])}"\n\n')
        f.write('[colors.bright]\n')
        f.write(f'black = "{hex_to_0x(colors["surface"])}"\n')
        f.write(f'red = "{hex_to_0x(colors["error"])}"\n')
        f.write(f'green = "{hex_to_0x(colors["secondary"])}"\n')
        f.write(f'yellow = "{hex_to_0x(colors["primary"])}"\n')
        f.write(f'blue = "{hex_to_0x(colors["primary"])}"\n')
        f.write(f'magenta = "{hex_to_0x(colors["secondary"])}"\n')
        f.write(f'cyan = "{hex_to_0x(colors["fg_alt"])}"\n')
        f.write(f'white = "{hex_to_0x(colors["fg_alt"])}"\n')

    with open(ROFI_COLORS, 'w') as f:
        f.write('* {\n')
        for k in ['bg', 'bg_alt', 'fg', 'fg_alt', 'primary', 'secondary', 'error', 'surface', 'outline']:
            rk = k.replace('error', 'urgent').replace('_', '-')
            f.write(f'    {rk}: {colors[k]};\n')
        f.write('}\n')

    with open(KITTY_COLORS, 'w') as f:
        f.write(f'background {colors["bg"]}\n')
        f.write(f'foreground {colors["fg"]}\n')
        f.write(f'selection_background {colors["primary"]}\n')
        f.write(f'selection_foreground {colors["bg"]}\n')
        f.write(f'url_color {colors["accent"]}\n\n')
        f.write(f'color0 {colors["bg_alt"]}\n')
        f.write(f'color1 {colors["error"]}\n')
        f.write(f'color2 {colors["secondary"]}\n')
        f.write(f'color3 {colors["primary"]}\n')
        f.write(f'color4 {colors["primary"]}\n')
        f.write(f'color5 {colors["secondary"]}\n')
        f.write(f'color6 {colors["fg_alt"]}\n')
        f.write(f'color7 {colors["fg"]}\n\n')
        f.write(f'color8 {colors["surface"]}\n')
        f.write(f'color9 {colors["error"]}\n')
        f.write(f'color10 {colors["secondary"]}\n')
        f.write(f'color11 {colors["primary"]}\n')
        f.write(f'color12 {colors["primary"]}\n')
        f.write(f'color13 {colors["secondary"]}\n')
        f.write(f'color14 {colors["fg_alt"]}\n')
        f.write(f'color15 {colors["fg_alt"]}\n\n')
        f.write(f'cursor {colors["fg"]}\n')
        f.write(f'cursor_text_color {colors["bg"]}\n')

    # GTK CSS override for dark theming
    GTK_CSS = os.path.expanduser("~/.config/gtk-3.0/gtk.css")
    with open(GTK_CSS, 'w') as f:
        f.write(f'window, dialog, .background {{ background-color: {colors["bg"]}; }}\n')
        f.write(f'.view, .content-view, textview text {{ background-color: {colors["bg_alt"]}; color: {colors["fg"]}; }}\n')
        f.write(f'button, entry, treeview {{ background-color: {colors["surface"]}; color: {colors["fg"]}; border-color: {colors["outline"]}; }}\n')
        f.write(f'menubar, menu, menuitem, .menu {{ background-color: {colors["bg"]}; color: {colors["fg"]}; }}\n')
        f.write(f'menuitem:hover, .menuitem:hover, treeview:selected {{ background-color: {colors["primary"]}; color: {colors["bg"]}; }}\n')
        f.write(f'tooltip {{ background-color: {colors["bg_alt"]}; color: {colors["fg"]}; border-color: {colors["outline"]}; }}\n')
        f.write(f'headerbar, toolbar, .titlebar {{ background-color: {colors["bg_alt"]}; color: {colors["fg"]}; border-color: {colors["outline"]}; }}\n')

    # Qt5ct palette override
    def qt_color(c):
        return f"#ff{c.lstrip('#')}"
    QT5CT = os.path.expanduser("~/.config/qt5ct/qt5ct.conf")
    QT6CT = os.path.expanduser("~/.config/qt6ct/qt6ct.conf")
    for qt_file in [QT5CT, QT6CT]:
        with open(qt_file, 'w') as f:
            f.write("[Appearance]\n")
            f.write("style=Default\n")
            f.write("icon_theme=breeze-dark\n")
            f.write("font=Hack,10,-1,5,50,0,0,0,0,0\n")
            f.write("custom_palette=true\n\n")
            f.write("[Fonts]\n")
            f.write("general=Hack,10,-1,5,50,0,0,0,0,0\n")
            f.write("fixed=Hack,10,-1,5,50,0,0,0,0,0\n\n")
            f.write("[Interface]\n")
            f.write("activate_item_on_single_click=1\n")
            f.write("buttonbox_layout=0\n")
            f.write("cursor_flash_time=1000\n")
            f.write("dialog_buttons_have_icons=1\n")
            f.write("double_click_interval=400\n")
            f.write("menus_have_icons=1\n")
            f.write("show_shortcuts_in_context_menus=1\n")
            f.write("spin_button_click_mode=0\n")
            f.write("splitter_width=4\n")
            f.write("toolbutton_style=4\n")
            f.write("wheel_scroll_lines=3\n\n")
            f.write("[Palette]\n")
            c = {k: qt_color(v) for k, v in colors.items()}
            active = f"{c['fg']}, {c['bg']}, {c['bg_alt']}, {c['surface']}, {c['surface']}, {c['outline']}, {c['fg']}, {c['fg_alt']}, {c['surface']}, {c['bg']}, {c['bg']}, #ff000000, {c['primary']}, {c['bg']}, {c['secondary']}, {c['surface']}, {c['bg']}, #ff000000, {c['bg']}, {c['fg']}, #ff000000, {c['fg_alt']}, {c['bg']}"
            inactive = active
            disabled = f"{c['outline']}, {c['bg_alt']}, {c['surface']}, {c['surface']}, {c['surface']}, {c['outline']}, {c['outline']}, {c['fg_alt']}, {c['surface']}, {c['bg_alt']}, {c['bg_alt']}, #ff000000, {c['surface']}, {c['outline']}, {c['secondary']}, {c['surface']}, {c['bg_alt']}, #ff000000, {c['bg_alt']}, {c['outline']}, #ff000000, {c['fg_alt']}, {c['bg_alt']}"
            f.write(f"active={active}\n")
            f.write(f"inactive={inactive}\n")
            f.write(f"disabled={disabled}\n")

    subprocess.Popen(["i3-msg", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.Popen(
        ["bash", "-c", "sleep 0.5; killall polybar 2>/dev/null; sleep 0.3; nohup polybar example &>/dev/null & disown"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    # Update betterlockscreen colors
    blsrc = os.path.expanduser("~/.config/betterlockscreen/betterlockscreenrc")
    with open(blsrc, 'w') as f:
        c = {k: v.lstrip('#') for k, v in colors.items()}
        f.write(f"i3lock_args=\"-e --force-clock")
        f.write(f" --timepos=x+960:y+540 --timecolor={colors['fg']}ff --datepos=x+960:y+580 --datecolor={colors['fg_alt']}ff")
        f.write(f" --ringcolor={colors['outline']}ff --insidecolor={colors['surface']}ff --keyhlcolor={colors['primary']}ff --bshlcolor={colors['error']}ff")
        f.write(f" --ringvercolor={colors['primary']}ff --ringwrongcolor={colors['error']}ff --verifcolor={colors['fg']}ff --wrongcolor={colors['error']}ff")
        f.write(f" --linecolor=00000000 --separatorcolor={colors['outline']}ff --locktext='' --lockfailedtext=''")
        f.write(f" --radius=80 --ring-width=6 --indpos=x+960:y+480")
        f.write(f" --time-font='Hack' --date-font='Hack' --timesize=36 --datesize=18")
        f.write(f" --timestr='%H:%M' --datestr='%A, %d %B'\"\n")
        f.write("off_cmd=\"xset dpms force off\"\n")

def get_wallpaper_files(ext_filter=None):
    files = []
    if not os.path.isdir(WALLPAPER_DIR):
        os.makedirs(WALLPAPER_DIR, exist_ok=True)
        return files
    for f in sorted(os.listdir(WALLPAPER_DIR)):
        ext = os.path.splitext(f)[1].lower()
        if ext_filter == "image" and ext not in IMAGE_EXTENSIONS:
            continue
        if ext_filter == "video" and ext not in VIDEO_EXTENSIONS:
            continue
        if ext in IMAGE_EXTENSIONS or ext in VIDEO_EXTENSIONS:
            files.append(f)
    return files

def rofi_menu(items, prompt="Select"):
    if not items:
        return None
    proc = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", prompt, "-format", "i"],
        input="\n".join(items), capture_output=True, text=True
    )
    if proc.returncode != 0:
        return None
    try:
        idx = int(proc.stdout.strip())
        return items[idx] if 0 <= idx < len(items) else None
    except ValueError:
        return proc.stdout.strip() or None

def apply_wallpaper(path, is_video=False):
    if is_video:
        frame_path = extract_first_frame(path)
        if os.path.exists(frame_path):
            colors = extract_colors(frame_path)
            subprocess.Popen(["betterlockscreen", "-u", frame_path, "--fx", "dim,blur", "--dim", "10", "--blur", "0.05"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            try:
                os.unlink(frame_path)
            except OSError:
                pass
        else:
            colors = DEFAULT_COLORS.copy()
        set_video_wallpaper(path)
    else:
        colors = extract_colors(path)
        subprocess.Popen(["betterlockscreen", "-u", path, "--fx", "dim,blur", "--dim", "10", "--blur", "0.05"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        kill_video_wallpaper()
        set_static_wallpaper(path)
    apply_colors(colors)
    return colors

def main():
    idle_active = os.path.exists(os.path.expanduser("~/.config/i3/idle-enabled"))
    idle_label = "On" if idle_active else "Off"

    menu_items = [
        "\uf03e  Wallpaper (Image)",
        "\uf03d  Wallpaper (Video)",
        "\uf26c  Display",
        "\uf294  Bluetooth",
        "\uf1eb  Network",
        "\uf028  Volume",
        "\uf023  Lock Screen",
        f"\uf1f6  Idle Lock: {idle_label}",
        "\uf2f1  Reload Theme",
        "\uf07b  Wallpaper Folder",
    ]

    choice = rofi_menu(menu_items, prompt="Settings")
    if not choice:
        return

    if "Wallpaper (Image)" in choice:
        files = get_wallpaper_files("image")
        if not files:
            subprocess.run(["notify-send", "Wallpaper", f"Put images in {WALLPAPER_DIR}"])
            return
        sel = rofi_menu(files, prompt="Image Wallpaper")
        if sel:
            apply_wallpaper(os.path.join(WALLPAPER_DIR, sel), is_video=False)
            subprocess.run(["notify-send", "Wallpaper", f"Applied: {sel}"])

    elif "Wallpaper (Video)" in choice:
        files = get_wallpaper_files("video")
        if not files:
            subprocess.run(["notify-send", "Wallpaper", f"Put videos in {WALLPAPER_DIR}"])
            return
        sel = rofi_menu(files, prompt="Video Wallpaper")
        if sel:
            apply_wallpaper(os.path.join(WALLPAPER_DIR, sel), is_video=True)
            subprocess.run(["notify-send", "Wallpaper", f"Applied: {sel}"])

    elif "Display" in choice:
        subprocess.Popen(["arandr"])

    elif "Bluetooth" in choice:
        subprocess.Popen(["blueman-manager"])

    elif "Network" in choice:
        subprocess.Popen(["kitty", "-e", "nmtui"])

    elif "Volume" in choice:
        subprocess.Popen(["pavucontrol"])

    elif "Lock Screen" in choice:
        subprocess.Popen(["betterlockscreen", "-l"])

    elif "Idle Lock" in choice:
        idle_flag = os.path.expanduser("~/.config/i3/idle-enabled")
        if idle_active:
            subprocess.run(["xautolock", "-disable"], capture_output=True)
            os.unlink(idle_flag)
            subprocess.run(["notify-send", "Idle Lock", "Disabled — screen will not auto-lock"])
        else:
            subprocess.run(["xautolock", "-enable"], capture_output=True)
            open(idle_flag, 'w').close()
            subprocess.run(["notify-send", "Idle Lock", "Enabled — lock after 10min, screen off after 30min"])

    elif "Reload Theme" in choice:
        if os.path.exists(CURRENT_WALL):
            with open(CURRENT_WALL) as f:
                line = f.readline().strip()
            if line.startswith("static:"):
                path = line.split(":", 1)[1]
                if os.path.exists(path):
                    apply_wallpaper(path, is_video=False)
            elif line.startswith("video:"):
                path = line.split(":")[1]
                if os.path.exists(path):
                    apply_wallpaper(path, is_video=True)
        else:
            subprocess.run(["notify-send", "Theme", "No current wallpaper found"])

    elif "Wallpaper Folder" in choice:
        subprocess.Popen(["thunar", WALLPAPER_DIR])

if __name__ == "__main__":
    main()
