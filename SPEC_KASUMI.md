# FLAVOR SPECIFICATION: KAZE KASUMI (霞)
**Category:** Aesthetic Wayland Ricing Workstation  
**Philosophy:** Motion fluidity, dynamic Material You color harmony, and hardware-accelerated QtQuick desktop shell.  
**Compositor:** Hyprland (Configured in Modular Lua)  
**Desktop Shell:** QuickShell (QML / QtQuick)  

---

## 1. Directory Tree & Config Structure

When Kaze Kasumi boots or installs, the default user environment is staged in `/etc/skel/.config/`:

```text
/etc/skel/.config/
├── hypr/
│   ├── hyprland.lua                     # Master entry point
│   ├── lua/
│   │   ├── settings.lua                 # Monitors, animations, gestures, layout
│   │   ├── devices.lua                  # Touchpad, mouse, keyboard configs
│   │   ├── binds.lua                    # Keybindings (Super-centric)
│   │   ├── window-rules.lua             # Window rules, opacity, QuickShell popups
│   │   ├── autostart.lua                # Startup daemons (awww, quickshell, polkit)
│   │   └── colors.lua                   # Dynamically overwritten by Matugen
│   └── scripts/                         # Legacy helper scripts
│
├── quickshell/
│   ├── shell.qml                        # Master entry point
│   ├── qmldir                           # Module declarations
│   ├── Theme.qml                        # Color token parser & theme state
│   ├── colors.json                      # Dynamically overwritten by Matugen
│   ├── Bar.qml                          # Top/bottom floating status bar
│   ├── Dashboard.qml                    # Control center (audio, brightness, network)
│   ├── Launcher.qml                     # Fuzzy application launcher
│   ├── NotificationPopup.qml            # Native notification manager & popups
│   ├── CalendarDropdown.qml             # Interactive calendar popup
│   ├── WallpaperPicker.qml              # Visual wallpaper grid picker
│   └── components/                      # Reusable QML widgets (sliders, buttons)
│
├── matugen/
│   ├── config.toml                      # Output template targets
│   └── templates/
│       ├── hyprland-colors.lua          # Lua template for Hyprland borders/accents
│       ├── quickshell-colors.json       # JSON template for QuickShell theme
│       └── ghostty-colors.conf          # Ghostty terminal color palette
│
└── ghostty/
    ├── config                           # Ghostty terminal configuration
    └── theme                            # Dynamically overwritten by Matugen
```

---

## 2. Dynamic Theming Pipeline (Matugen + Awww)

### Configuration Template (`~/.config/matugen/config.toml`)
```toml
[config]

[templates.hyprland]
input_path  = "~/.config/matugen/templates/hyprland-colors.lua"
output_path = "~/.config/hypr/lua/colors.lua"

[templates.quickshell]
input_path  = "~/.config/matugen/templates/quickshell-colors.json"
output_path = "~/.config/quickshell/colors.json"

[templates.ghostty]
input_path  = "~/.config/matugen/templates/ghostty-colors.conf"
output_path = "~/.config/ghostty/theme"
```

### Theming Event Chain:
1. User triggers wallpaper change via `kaze-cli wallpaper /path/to/img` or the QuickShell `WallpaperPicker.qml`.
2. `awww img "<path>" --transition-type wipe --transition-step 90 --transition-fps 144 &` initiates an ultra-smooth GPU wipe animation.
3. `matugen image "<path>" --type scheme-tonal-spot -c ~/.config/matugen/config.toml` extracts tonal palettes and writes the three output files.
4. Signals sent:
   - `quickshell ipc call theme reload` -> QuickShell updates interface colors with zero flicker.
   - `hyprctl reload` -> Hyprland updates active window border gradient and drop-shadow colors.
   - Ghostty detects file change on `~/.config/ghostty/theme` and updates terminal colors live.

---

## 3. The `kaze-cli` Management Utility

The `kaze-cli` utility is written in Python with zero external dependencies (uses standard library and system commands).

### Command Reference:
- `kaze-cli wallpaper [random | <file>]`:
  Selects a wallpaper from `/usr/share/backgrounds/kaze/` or a custom path, caches the path in `~/.cache/kaze-wallpaper`, and triggers the theme update chain.
- `kaze-cli scheme [tonal-spot | vibrant | expressive | neutral]`:
  Re-runs Matugen on the current cached wallpaper using a different tonal mood without changing the image.
- `kaze-cli sync`:
  Fetches upstream Kaze Kasumi dotfile updates from Git. Creates a timestamped backup in `~/.config/kaze-backup-<timestamp>/` and prompts the user before applying diffs.
- `kaze-cli doctor`:
  Runs pre-flight diagnostic tests:
  - Validates `awww-daemon` is running.
  - Validates `quickshell` process is alive.
  - Verifies audio daemon (`wireplumber`) and Bluetooth status.
  - Validates GPU acceleration (`eglinfo` / `vulkaninfo`).

---

## 4. Package Manifest (`flavors/kasumi/packages.flavor`)

```text
# Compositor & Wayland Essentials
hyprland
hyprlock
hypridle
xdg-desktop-portal-hyprland
polkit-kde-agent
qt5-wayland
qt6-wayland
wl-clipboard
grim
slurp
swappy

# Shell & UI (From [kaze] custom repo)
quickshell
matugen
awww
ghostty
kaze-cli
kaze-branding

# Fonts & Icons
ttf-jetbrains-mono-nerd
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
papirus-icon-theme

# Utilities
yazi
ffmpegthumbnailer
pavucontrol
blueman
```
