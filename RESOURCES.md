# KAZE OS: DEVELOPER RESOURCES & REFERENCE GUIDE
**Project Umbrella:** Kaze OS (風)  
**Target Environment:** Arch Linux Development System  

---

## 1. Upstream Repositories & Key Tools

### 1.1 Core Arch Distribution Infrastructure
- **`archiso`**: Official Arch Linux live image generator.
  - Upstream: `https://gitlab.archlinux.org/archlinux/archiso`
  - Docs: `https://wiki.archlinux.org/title/Archiso`
- **`Calamares`**: The universal distribution-independent graphical installer.
  - Upstream: `https://github.com/calamares/calamares`
  - Docs: `https://calamares.io/docs/`
- **`snapper` & `snap-pac`**: Automated Btrfs snapshot engine.
  - Snapper: `http://snapper.io/`
  - snap-pac: `https://github.com/wesman/snap-pac`
  - grub-btrfs: `https://github.com/Antynea/grub-btrfs`

### 1.2 Performance & Low-Latency Ecosystem (Kaze Hayate)
- **CachyOS Kernels & Repositories**:
  - Main site: `https://cachyos.org/`
  - Kernel sources & patches: `https://github.com/CachyOS/linux-cachyos`
  - BORE Scheduler: `https://github.com/firelzrd/bore-scheduler`
- **Ananicy-CPP**: C++ Auto-nice daemon.
  - Upstream: `https://gitlab.com/ananicy-cpp/ananicy-cpp`
  - Rules: `https://github.com/CachyOS/cachyos-ananicy-rules`
- **Feral GameMode**:
  - Upstream: `https://github.com/FeralInteractive/gamemode`

### 1.3 Wayland Ricing & UI Ecosystem (Kaze Kasumi)
- **Tier 1 (Guaranteed Official Core)**:
  - **Hyprland**: Modern dynamic tiling Wayland compositor (`https://wiki.hyprland.org/`).
  - **Kitty**: High-performance, GPU-accelerated terminal (`https://sw.kovidgoyal.net/kitty/`).
  - **Waybar**: Highly customizable Wayland bar with CSS styling (`https://github.com/Alexays/Waybar`).
  - **Fuzzel**: Lightweight Wayland application launcher (`https://codeberg.org/dnkl/fuzzel`).
  - **Hyprpaper / Swaybg**: Fast wallpaper rendering engines.
  - **Hyprlock & Hypridle**: Native Wayland screen locking and idle management.
- **Tier 2 (Custom & AUR Rice Enhancements)**:
  - **QuickShell**: QtQuick / QML desktop shell framework for Wayland (`https://git.outfoxxed.me/outfoxxed/quickshell`).
  - **Matugen**: Material You dynamic color palette generator (`https://github.com/InioX/matugen`).
  - **awww**: Modern hardware-accelerated Wayland wallpaper daemon (`https://github.com/LGFae/awww`).
  - **Ghostty**: Fast GPU-accelerated terminal emulator (`https://ghostty.org/`).

---

## 2. Local Developer Workstation Setup

To compile packages and build Kaze OS ISOs on your local machine, install the developer toolchain:

```bash
# Core build dependencies
sudo pacman -S --needed \
    archiso \
    devtools \
    base-devel \
    git \
    rsync \
    qemu-desktop \
    qemu-emulators-full \
    edk2-ovmf \
    reflector
```

---

## 3. Developer Cheatsheet & Common Commands

### 3.1 Building an ISO Locally
```bash
# Build the Aesthetic Rice (Kasumi) ISO
sudo ./build.sh --flavor kasumi

# Build the Performance (Hayate) ISO
sudo ./build.sh --flavor hayate

# Build the Daily Driver (Nagomi) ISO
sudo ./build.sh --flavor nagomi

# Clean previous build artifacts
sudo ./build.sh --clean
```

### 3.2 Testing the Generated ISO in QEMU (UEFI Mode)
```bash
# Run QEMU with 8GB RAM, 4 CPU cores, and UEFI firmware
qemu-system-x86_64 \
    -enable-kvm \
    -m 8G \
    -smp 4 \
    -vga virtio \
    -display default,show-cursor=on \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.fd \
    -cdrom out/kaze-kasumi-1.0.0-x86_64.iso \
    -boot d
```

### 3.3 Compiling PKGBUILDs in a Clean Chroot
Avoid building packages on your host system directly; use `devtools` to ensure clean dependencies:

```bash
cd pkgs/kaze-cli

# Build package in isolated clean chroot
extra-x86_64-build

# Update local repo database with newly built package
repo-add ../../repo/x86_64/kaze.db.tar.gz *.pkg.tar.zst
```

---

## 4. Repository Mirror List Setup

To consume CachyOS pre-compiled packages in Kaze Hayate, add the following keyring and mirrors to `/etc/pacman.conf`:

```ini
# Add CachyOS Keyring & Mirrors
# curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
# tar xvf cachyos-repo.tar.xz && sudo ./cachyos-repo/cachyos-repo.sh

[cachyos-v3]
Server = https://mirror.cachyos.org/repo/x86_64_v3/$repo/os/$arch

[cachyos]
Server = https://mirror.cachyos.org/repo/$arch/$repo
```
