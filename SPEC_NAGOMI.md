# FLAVOR SPECIFICATION: KAZE NAGOMI (和)
**Category:** Daily Driver Workstation & Production Desktop  
**Philosophy:** Stability, seamless graphical application management, automated recovery, and extended laptop battery life.  
**Default Desktop:** KDE Plasma 6 (Wayland) with GNOME installer toggle  
**Software Delivery:** Discover + Flathub (Sandboxed Apps) + Octopi / Pacman GUI  

---

## 1. Desktop Experience & Workstation Polishing

Kaze Nagomi delivers an experience tailored for developers, students, and everyday users who require zero command-line maintenance for daily workflows.

### 1.1 Desktop Interface (KDE Plasma 6 on Wayland)
- Native per-monitor fractional scaling (125%, 150%, 175%).
- Out-of-the-box Night Light (blue light reduction scheduled by sunset/sunrise).
- Integrated touchpad gesture navigation (3-finger swipe for virtual desktops, pinch to zoom).
- SDDM login manager with custom Kaze Nagomi theme.

### 1.2 The GNOME Alternative Option
During the Calamares installation process, an advanced option allows switching the target desktop to **GNOME 46+** for users who prefer gesture-driven workflows.

---

## 2. Software Delivery & App Stores

Kaze Nagomi bridges the power of Arch Linux with the safety of sandboxed app distribution:

### 2.1 Discover Software Center + Flathub
- Configured out of the box with the Flathub remote.
- Sandboxed desktop applications (Spotify, Steam, Discord, Chrome, LibreOffice, Obsidian) install with a single click without requiring terminal compilation or root passwords.
- Automatic background update notifications through system tray.

### 2.2 Advanced Package Management
- Native integration with Arch Linux official repositories: `[core]`, `[extra]`, and `[multilib]`.
- Custom `[kaze]` repository for distribution utilities and wallpapers.
- Seamless CLI package workflows via `pacman` and `kaze-cli`.

---

## 3. Power, Hardware & Connectivity Optimization

### 3.1 Laptop Power Management (`power-profiles-daemon`)
Seamlessly integrated into Plasma's battery system tray widget:
- **Power Saver**: Lowers CPU clock limits, dims display aggressively, spins down non-critical hardware.
- **Balanced**: Standard dynamic governor for everyday browsing and development.
- **Performance**: Elevates thermal throttling ceilings for intense compiling or video export.

### 3.2 Hardware Video & Audio Stack
- Pre-installed VA-API and VDPAU video acceleration drivers for Intel (`intel-media-driver`), AMD (`libva-mesa-driver`), and Nvidia.
- Full PipeWire Bluetooth audio stack with high-fidelity codecs:
  - `libfreeaptx` (aptX / aptX HD)
  - `ldacBT` (Sony LDAC high-resolution)
  - `pipewire-pulse` and `wireplumber`
- Plug-and-play printer discovery: `cups` and `avahi-daemon` are enabled by default.

---

## 4. First-Boot Welcome Wizard (`kaze-welcome`)

When the user logs in for the first time, a clean PySide6/QML window appears:

1. **Optimize Download Mirrors**: Runs `reflector` with optimal geographical latency filters.
2. **Proprietary Driver Check**: Detects discrete GPUs (e.g. Nvidia RTX/GTX) and prompts for one-click driver installation.
3. **Software Quick-Picks**: Checkboxes to install Web Browsers (Firefox, Brave, Chrome), Productivity Suites (LibreOffice), and Development Tools (VS Code, Docker).
4. **Snapshot Protection Indicator**: Displays a green badge confirming that Btrfs Snapper protection is active.

---

## 5. Package Manifest (`flavors/nagomi/packages.flavor`)

```text
# Desktop Environment (KDE Plasma 6)
plasma-meta
plasma-wayland-session
kde-applications-meta
sddm
sddm-kcm
kinfocenter
dolphin
konsole
kate
spectacle
ark

# Software Stores & Flatpak
discover
packagekit-qt6
flatpak

# Power & Hardware
power-profiles-daemon
intel-media-driver
libva-mesa-driver
libfreeaptx
bluez
bluez-utils
cups
system-config-printer
avahi
nss-mdns

# Welcome App & Distro Tools
kaze-welcome
kaze-branding
kaze-cli
```
