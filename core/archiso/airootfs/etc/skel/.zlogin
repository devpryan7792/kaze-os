# ==============================================================================
# KAZE OS: USER ZLOGIN (~/.zlogin)
# ==============================================================================

# Autostart Hyprland live session on tty1
if [[ -z "$WAYLAND_DISPLAY" && -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    if [[ -x /usr/bin/Hyprland ]]; then
        export XDG_CURRENT_DESKTOP=Hyprland
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=Hyprland
        exec Hyprland
    fi
fi
