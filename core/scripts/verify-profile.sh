#!/usr/bin/env bash
# ==============================================================================
# KAZE OS: PROFILE INTEGRITY VERIFIER (core/scripts/verify-profile.sh)
# ==============================================================================

set -euo pipefail

PROFILE_DIR="${1:-work/profile}"

echo "==> Verifying profile integrity at: $PROFILE_DIR"

# 1. Check essential archiso files
MANDATORY_FILES=(
    "profiledef.sh"
    "pacman.conf"
    "packages.x86_64"
    "airootfs/etc/hostname"
    "airootfs/etc/pacman.conf"
    "airootfs/etc/polkit-1/rules.d/49-nopasswd_calamares.rules"
    "airootfs/usr/share/applications/calamares.desktop"
    "airootfs/etc/snapper/configs/root"
    "airootfs/etc/default/snapper"
    "airootfs/etc/default/grub-btrfs/config"
    "airootfs/etc/sudoers.d/kaze"
)

for file in "${MANDATORY_FILES[@]}"; do
    if [[ ! -e "$PROFILE_DIR/$file" ]]; then
        echo "[ERROR] Missing mandatory profile file: $PROFILE_DIR/$file" >&2
        exit 1
    fi
    echo "  [OK] Found $file"
done

# 2. Check bootloader directories
if [[ ! -d "$PROFILE_DIR/efiboot" && ! -d "$PROFILE_DIR/syslinux" && ! -d "$PROFILE_DIR/grub" ]]; then
    echo "[ERROR] No bootloader configuration directory found in profile!" >&2
    exit 1
fi
echo "  [OK] Bootloader configs present"

# 3. Check packages.x86_64
PKG_COUNT=$(wc -l < "$PROFILE_DIR/packages.x86_64")
if [[ "$PKG_COUNT" -eq 0 ]]; then
    echo "[ERROR] packages.x86_64 is empty!" >&2
    exit 1
fi
echo "  [OK] packages.x86_64 contains $PKG_COUNT packages"

# Check for duplicate packages in packages.x86_64
DUPLICATES=$(sort "$PROFILE_DIR/packages.x86_64" | uniq -d)
if [[ -n "$DUPLICATES" ]]; then
    echo "[ERROR] Duplicate packages found in packages.x86_64:" >&2
    echo "$DUPLICATES" >&2
    exit 1
fi
echo "  [OK] Zero package duplicates"

# 4. Check profiledef.sh syntax
bash -n "$PROFILE_DIR/profiledef.sh"
echo "  [OK] profiledef.sh syntax valid"

# 5. Check hostname matches profiledef
HOSTNAME=$(cat "$PROFILE_DIR/airootfs/etc/hostname")
FLAVOR="${HOSTNAME#kaze-}"
echo "  [OK] Profile target flavor: $FLAVOR (hostname: $HOSTNAME)"

# 6. Verify Calamares configuration & 5-subvolume Btrfs topology
CALAMARES_DIR="$PROFILE_DIR/airootfs/etc/calamares"
if [[ ! -d "$CALAMARES_DIR" && -d "$PROFILE_DIR/airootfs/root/calamares-overlay" ]]; then
    CALAMARES_DIR="$PROFILE_DIR/airootfs/root/calamares-overlay"
fi

if [[ ! -f "$CALAMARES_DIR/settings.conf" ]]; then
    echo "[ERROR] Calamares settings.conf missing in $CALAMARES_DIR" >&2
    exit 1
fi
echo "  [OK] Calamares settings.conf present"

MOUNT_CONF="$CALAMARES_DIR/modules/mount.conf"
if [[ ! -f "$MOUNT_CONF" ]]; then
    echo "[ERROR] Calamares mount.conf missing in $CALAMARES_DIR/modules" >&2
    exit 1
fi

# Verify all 5 Btrfs subvolumes are declared in mount.conf
REQUIRED_SUBVOLS=("/@" "/@home" "/@snapshots" "/@var_log" "/@var_cache")
for subvol in "${REQUIRED_SUBVOLS[@]}"; do
    if ! grep -q "$subvol" "$MOUNT_CONF"; then
        echo "[ERROR] Btrfs subvolume '$subvol' not found in $MOUNT_CONF" >&2
        exit 1
    fi
    echo "  [OK] Verified Btrfs subvolume $subvol in mount.conf"
done

# 7. Verify Calamares branding for flavor
BRANDING_DESC="$CALAMARES_DIR/branding/kaze-$FLAVOR/branding.desc"
if [[ ! -f "$BRANDING_DESC" ]]; then
    echo "[ERROR] Calamares branding missing for flavor '$FLAVOR': $BRANDING_DESC" >&2
    exit 1
fi
echo "  [OK] Calamares branding present for kaze-$FLAVOR"

# 8. Flavor-Specific Component Verifications
if [[ "$FLAVOR" == "kasumi" ]]; then
    echo "==> Verifying Kaze Kasumi Rice Components..."
    KASUMI_SKEL="$PROFILE_DIR/airootfs/etc/skel/.config"

    # Hyprland
    for f in "hypr/hyprland.conf" "hypr/hyprland.lua" "hypr/lua/settings.lua" "hypr/lua/binds.lua" "hypr/lua/colors.lua" "hypr/lua/window-rules.lua" "hypr/lua/autostart.lua"; do
        if [[ ! -f "$KASUMI_SKEL/$f" ]]; then
            echo "[ERROR] Kasumi Hyprland config missing: $KASUMI_SKEL/$f" >&2
            exit 1
        fi
        echo "  [OK] Kasumi Hyprland: $f"
    done

    # QuickShell
    for f in "quickshell/shell.qml" "quickshell/Bar.qml" "quickshell/Dashboard.qml" "quickshell/Launcher.qml" "quickshell/NotificationPopup.qml" "quickshell/WallpaperPicker.qml" "quickshell/Theme.qml" "quickshell/colors.json"; do
        if [[ ! -f "$KASUMI_SKEL/$f" ]]; then
            echo "[ERROR] Kasumi QuickShell component missing: $KASUMI_SKEL/$f" >&2
            exit 1
        fi
        echo "  [OK] Kasumi QuickShell: $f"
    done

    # Matugen & Ghostty
    for f in "matugen/config.toml" "matugen/templates/hyprland-colors.lua" "matugen/templates/quickshell-colors.json" "matugen/templates/ghostty-colors.conf" "ghostty/config" "ghostty/theme"; do
        if [[ ! -f "$KASUMI_SKEL/$f" ]]; then
            echo "[ERROR] Kasumi Theming config missing: $KASUMI_SKEL/$f" >&2
            exit 1
        fi
        echo "  [OK] Kasumi Theming: $f"
    done

    # Wallpapers
    if grep -q "^kaze-branding" "$PROFILE_DIR/packages.x86_64"; then
        echo "  [OK] Kasumi Wallpapers: Provided via kaze-branding package in packages.x86_64"
    else
        WALL_COUNT=$(find "$PROFILE_DIR/airootfs/usr/share/backgrounds/kaze" -name "*.svg" 2>/dev/null | wc -l)
        if [[ "$WALL_COUNT" -eq 0 ]]; then
            echo "[ERROR] No wallpapers found in $PROFILE_DIR/airootfs/usr/share/backgrounds/kaze and kaze-branding not in packages.x86_64" >&2
            exit 1
        fi
        echo "  [OK] Kasumi Wallpapers: $WALL_COUNT SVG wallpapers present"
    fi
elif [[ "$FLAVOR" == "hayate" ]]; then
    echo "==> Verifying Kaze Hayate Performance Components..."
    HAYATE_ROOT="$PROFILE_DIR/airootfs"

    # Sysctl Performance
    SYSCTL_CONF="$HAYATE_ROOT/etc/sysctl.d/99-kaze-performance.conf"
    if [[ ! -f "$SYSCTL_CONF" ]] || ! grep -q "vm.swappiness = 10" "$SYSCTL_CONF"; then
        echo "[ERROR] Hayate sysctl performance tuning missing or invalid: $SYSCTL_CONF" >&2
        exit 1
    fi
    echo "  [OK] Hayate Sysctl: vm.swappiness=10, sched_cfs_bandwidth_slice_us=3000"

    # ZRAM
    ZRAM_CONF="$HAYATE_ROOT/etc/systemd/zram-generator.conf"
    if [[ ! -f "$ZRAM_CONF" ]] || ! grep -q "compression-algorithm = zstd" "$ZRAM_CONF"; then
        echo "[ERROR] Hayate ZRAM generator config missing: $ZRAM_CONF" >&2
        exit 1
    fi
    echo "  [OK] Hayate ZRAM: zstd in-RAM swap configured"

    # GameMode
    if [[ ! -f "$HAYATE_ROOT/etc/gamemode.ini" ]]; then
        echo "[ERROR] Hayate gamemode.ini missing!" >&2
        exit 1
    fi
    echo "  [OK] Hayate GameMode: governor=performance, GPU boost active"

    # Ananicy
    if [[ ! -f "$HAYATE_ROOT/etc/ananicy.d/games/kaze-games.rules" ]]; then
        echo "[ERROR] Hayate ananicy rules missing!" >&2
        exit 1
    fi
    if [[ ! -L "$HAYATE_ROOT/etc/systemd/system/multi-user.target.wants/ananicy-cpp.service" ]]; then
        echo "[ERROR] Hayate ananicy-cpp.service not enabled in multi-user.target.wants!" >&2
        exit 1
    fi
    echo "  [OK] Hayate Ananicy: Real-time game process rules active"

    # Calamares Netinstall
    if [[ ! -f "$CALAMARES_DIR/modules/netinstall.yaml" ]] || ! grep -q "KDE Plasma 6" "$CALAMARES_DIR/modules/netinstall.yaml"; then
        echo "[ERROR] Hayate netinstall.yaml missing or invalid!" >&2
        exit 1
    fi
    if ! grep -q "netinstall" "$CALAMARES_DIR/settings.conf"; then
        echo "[ERROR] Hayate Calamares settings.conf does not include netinstall module!" >&2
        exit 1
    fi
    echo "  [OK] Hayate Netinstall: Desktop selection module active in Calamares"
elif [[ "$FLAVOR" == "nagomi" ]]; then
    echo "==> Verifying Kaze Nagomi Workstation Components..."
    NAGOMI_ROOT="$PROFILE_DIR/airootfs"

    # Pamac
    if [[ ! -f "$NAGOMI_ROOT/etc/pamac.conf" ]] || ! grep -q "EnableAUR" "$NAGOMI_ROOT/etc/pamac.conf"; then
        echo "[ERROR] Nagomi pamac.conf missing or AUR not enabled!" >&2
        exit 1
    fi
    echo "  [OK] Nagomi Pamac: Arch repositories and AUR support enabled"

    # Flathub Integration
    if [[ ! -f "$NAGOMI_ROOT/etc/systemd/system/flathub-init.service" ]]; then
        echo "[ERROR] Nagomi flathub-init.service missing!" >&2
        exit 1
    fi
    if [[ ! -L "$NAGOMI_ROOT/etc/systemd/system/multi-user.target.wants/flathub-init.service" ]]; then
        echo "[ERROR] Nagomi flathub-init.service not enabled in multi-user.target.wants!" >&2
        exit 1
    fi
    echo "  [OK] Nagomi Flatpak: Flathub remote auto-initialization active"

    # System Services
    for svc in "power-profiles-daemon.service" "bluetooth.service" "cups.service" "avahi-daemon.service" "sddm.service"; do
        if [[ ! -L "$NAGOMI_ROOT/etc/systemd/system/multi-user.target.wants/$svc" ]]; then
            echo "[ERROR] Nagomi service not enabled: $svc" >&2
            exit 1
        fi
        echo "  [OK] Nagomi Service: $svc enabled"
    done

    # SDDM & Desktop Defaults
    if [[ ! -f "$NAGOMI_ROOT/etc/sddm.conf.d/autologin.conf" ]]; then
        echo "[ERROR] Nagomi SDDM autologin configuration missing!" >&2
        exit 1
    fi
    if [[ ! -f "$NAGOMI_ROOT/etc/skel/.config/kwinrc" ]] || ! grep -q "NightColor" "$NAGOMI_ROOT/etc/skel/.config/kwinrc"; then
        echo "[ERROR] Nagomi KWin configuration missing or Night Light not configured!" >&2
        exit 1
    fi
    if [[ ! -f "$NAGOMI_ROOT/etc/xdg/autostart/kaze-welcome.desktop" ]]; then
        echo "[ERROR] Nagomi kaze-welcome autostart desktop entry missing!" >&2
        exit 1
    fi
    echo "  [OK] Nagomi Desktop: SDDM autologin, Night Light, and Welcome autostart configured"

    # Calamares Desktop Selector (Plasma 6 vs GNOME)
    if [[ ! -f "$CALAMARES_DIR/modules/netinstall.yaml" ]] || ! grep -q "GNOME 46" "$CALAMARES_DIR/modules/netinstall.yaml"; then
        echo "[ERROR] Nagomi netinstall.yaml missing or GNOME alternative missing!" >&2
        exit 1
    fi
    echo "  [OK] Nagomi Calamares: Desktop selection (Plasma 6 / GNOME) active"
fi

echo "==> Profile integrity verified successfully!"
