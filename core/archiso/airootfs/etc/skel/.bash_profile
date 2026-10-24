# ==============================================================================
# KAZE OS: USER BASH PROFILE (~/.bash_profile)
# ==============================================================================

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z "$WAYLAND_DISPLAY" && -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    if [[ -x /usr/bin/Hyprland ]]; then
        export XDG_CURRENT_DESKTOP=Hyprland
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=Hyprland
        exec Hyprland
    fi
fi
