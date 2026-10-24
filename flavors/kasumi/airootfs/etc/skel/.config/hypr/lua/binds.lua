-- ==============================================================================
-- KAZE KASUMI: ERGONOMIC KEYBINDINGS (hypr/lua/binds.lua)
-- ==============================================================================

return {
    main_mod = "SUPER",
    binds = {
        -- Core Applications
        { "SUPER", "Return", "exec, ghostty" },
        { "SUPER", "Space", "exec, quickshell ipc call launcher toggle" },
        { "SUPER", "d", "exec, quickshell ipc call dashboard toggle" },
        { "SUPER", "w", "exec, quickshell ipc call wallpaperPicker toggle" },
        { "SUPER", "e", "exec, ghostty -e yazi" },
        { "SUPER,SHIFT", "w", "exec, kaze-cli wallpaper random" },

        -- Window Management
        { "SUPER", "q", "killactive," },
        { "SUPER,SHIFT", "q", "exit," },
        { "SUPER", "v", "togglefloating," },
        { "SUPER", "f", "fullscreen, 0" },
        { "SUPER,SHIFT", "f", "fullscreen, 1" },
        { "SUPER", "p", "pseudo," },
        { "SUPER", "t", "togglesplit," },

        -- Focus Navigation (Vim & Arrows)
        { "SUPER", "h", "movefocus, l" },
        { "SUPER", "l", "movefocus, r" },
        { "SUPER", "k", "movefocus, u" },
        { "SUPER", "j", "movefocus, d" },
        { "SUPER", "left", "movefocus, l" },
        { "SUPER", "right", "movefocus, r" },
        { "SUPER", "up", "movefocus, u" },
        { "SUPER", "down", "movefocus, d" },

        -- Window Movement
        { "SUPER,SHIFT", "h", "movewindow, l" },
        { "SUPER,SHIFT", "l", "movewindow, r" },
        { "SUPER,SHIFT", "k", "movewindow, u" },
        { "SUPER,SHIFT", "j", "movewindow, d" },

        -- Workspaces (1 - 9)
        { "SUPER", "1", "workspace, 1" },
        { "SUPER", "2", "workspace, 2" },
        { "SUPER", "3", "workspace, 3" },
        { "SUPER", "4", "workspace, 4" },
        { "SUPER", "5", "workspace, 5" },
        { "SUPER", "6", "workspace, 6" },
        { "SUPER", "7", "workspace, 7" },
        { "SUPER", "8", "workspace, 8" },
        { "SUPER", "9", "workspace, 9" },

        -- Move Window to Workspace
        { "SUPER,SHIFT", "1", "movetoworkspace, 1" },
        { "SUPER,SHIFT", "2", "movetoworkspace, 2" },
        { "SUPER,SHIFT", "3", "movetoworkspace, 3" },
        { "SUPER,SHIFT", "4", "movetoworkspace, 4" },
        { "SUPER,SHIFT", "5", "movetoworkspace, 5" },
        { "SUPER,SHIFT", "6", "movetoworkspace, 6" },
        { "SUPER,SHIFT", "7", "movetoworkspace, 7" },
        { "SUPER,SHIFT", "8", "movetoworkspace, 8" },
        { "SUPER,SHIFT", "9", "movetoworkspace, 9" },

        -- Scratchpad Special Workspace
        { "SUPER", "s", "togglespecialworkspace, magic" },
        { "SUPER,SHIFT", "s", "movetoworkspace, special:magic" },

        -- Screenshots & Snipping
        { "", "Print", "exec, grim -g \"$(slurp)\" - | wl-copy && notify-send 'Kaze OS' 'Selection copied to clipboard'" },
        { "SHIFT", "Print", "exec, grim ~/Pictures/$(date +'%Y-%m-%d_%H%M%S.png') && notify-send 'Kaze OS' 'Full screenshot saved to Pictures'" },

        -- Hardware Media & Volume Controls (e = repeat on hold)
        { "", "XF86AudioRaiseVolume", "exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+" },
        { "", "XF86AudioLowerVolume", "exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
        { "", "XF86AudioMute", "exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
        { "", "XF86MonBrightnessUp", "exec, brightnessctl set +5%" },
        { "", "XF86MonBrightnessDown", "exec, brightnessctl set 5%-" },
        { "", "XF86AudioPlay", "exec, playerctl play-pause" },
        { "", "XF86AudioNext", "exec, playerctl next" },
        { "", "XF86AudioPrev", "exec, playerctl previous" }
    }
}
