# Autostart Hyprland live session on tty1
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
    if [ -x /usr/bin/Hyprland ]; then
        if [ "$(id -u)" -eq 0 ]; then
            exec Hyprland --i-am-really-stupid
        else
            exec Hyprland
        fi
    fi
fi
