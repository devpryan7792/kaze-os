# KAZE OS: STRATEGIC IMPLEMENTATION ROADMAP
**Status:** Ready for Execution  
**Target Architecture:** x86_64 (with x86-64-v3 optimizations)  
**Base Distribution:** Arch Linux  

---

## Overview

This roadmap defines the execution phases, sequential milestones, deliverables, verification gates, and risk mitigations for developing and deploying **Kaze OS** across its three flavors:
- **Kaze Hayate** (Performance & Gaming)
- **Kaze Kasumi** (Aesthetic Wayland Rice)
- **Kaze Nagomi** (Daily Driver Workstation)

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ROADMAP EXECUTION PHASES                        │
└────────────────────────────────────────────────────────────────────────┘
 [Phase 0: Workspace Foundation & Core Archiso Engine]
                     │
                     ▼
 [Phase 1: Custom Package Repository & Tooling (PKGBUILDs)]
                     │
                     ▼
 [Phase 2: Universal Calamares Installer & Automated Btrfs Engine]
                     │
                     ▼
 [Phase 3: Flavor Implementation - Kasumi (Aesthetic Rice)]
                     │
                     ▼
 [Phase 4: Flavor Implementation - Hayate (Performance & Gaming)]
                     │
                     ▼
 [Phase 5: Flavor Implementation - Nagomi (Daily Driver)]
                     │
                     ▼
 [Phase 6: GitHub Actions CI/CD & Automated ISO Release Pipeline]
                     │
                     ▼
 [Phase 7: End-to-End Verification & Production Readiness]
```

---

## Phase 0: Workspace Foundation & Core Archiso Engine

**Objective**: Establish the monorepo layout, extract upstream Arch Linux `releng` base, and create the multi-flavor build orchestration script.

### Milestones & Deliverables
- [ ] **M0.1: Directory Tree Initialization**
  - Create directory skeleton:
    ```bash
    mkdir -p core/archiso core/calamares core/scripts
    mkdir -p flavors/{hayate,kasumi,nagomi}/{airootfs,calamares}
    mkdir -p pkgs/{kaze-cli,kaze-welcome,kaze-branding}
    mkdir -p repo/x86_64 out work
    ```
- [ ] **M0.2: Extract Upstream Archiso `releng` Base**
  - Copy `/usr/share/archiso/configs/releng/` into `core/archiso/`.
  - Remove unwanted upstream profiles while preserving bootloader configurations (`efiboot`, `syslinux`).
- [ ] **M0.3: Define Shared Base Packages (`core/packages.common`)**
  - Specify universal packages required for live boot and networking:
    - Base system: `base`, `linux-firmware`, `base-devel`, `btrfs-progs`, `e2fsprogs`, `dosfstools`
    - Networking: `networkmanager`, `iwd`, `wireless_tools`, `wpa_supplicant`, `curl`, `wget`, `git`
    - Audio/Video basics: `pipewire`, `pipewire-pulse`, `wireplumber`, `mesa`
    - Administration: `sudo`, `neovim`, `nano`, `which`, `reflector`
- [ ] **M0.4: Master Build Engine Script (`build.sh`)**
  - Implement `./build.sh --flavor [hayate|kasumi|nagomi] [--clean] [--work-dir <path>]`.
  - Support overlay merging:
    1. Merge `core/archiso` into working profile.
    2. Append `flavors/<flavor>/packages.flavor` to `packages.x86_64`.
    3. Copy `flavors/<flavor>/airootfs` recursively over `work/profile/airootfs`.
    4. Inject `pacman.conf` with local/custom repo support.
    5. Invoke `mkarchiso -v -w <work> -o <out> <profile>`.

### Verification Gate (Exit Criteria)
- Running `./build.sh --flavor kasumi` compiles a minimal, bootable test ISO that boots in QEMU into a bash shell with working internet connectivity.

---

## Phase 1: Custom Package Repository & Tooling

**Objective**: Build PKGBUILDs for packages not in official Arch repos, create a local Pacman repository database, and establish GitHub Pages hosting.

### Milestones & Deliverables
- [ ] **M1.1: Build PKGBUILD for `kaze-branding`**
  - Assets: Default vector logos, plymouth splash screen, Kaze wallpaper collection.
  - Target install location: `/usr/share/backgrounds/kaze/`, `/usr/share/plymouth/themes/kaze/`.
- [ ] **M1.2: Build PKGBUILD for `kaze-cli`**
  - Develop Python/Bash system management tool:
    - `kaze-cli wallpaper`: Set wallpaper, trigger 144Hz awww transition, update Matugen tokens.
    - `kaze-cli scheme`: Change Material You palette tone.
    - `kaze-cli sync`: Pull upstream dotfile revisions with automated backup.
    - `kaze-cli doctor`: System diagnostic check.
  - Install to `/usr/bin/kaze-cli`.
- [ ] **M1.3: Package External Upstream Binaries**
  - Author or vendor PKGBUILDs:
    - `matugen-bin` (Material You color generator)
    - `awww-bin` (144Hz Wayland wallpaper daemon)
    - `quickshell-git` (QtQuick Wayland desktop shell)
    - `ghostty-bin` (GPU terminal)
- [ ] **M1.4: Repository Database Generation (`repo/update-repo.sh`)**
  - Build all packages in a clean chroot via `devtools` (`extra-x86_64-build`).
  - Execute `repo-add repo/x86_64/kaze.db.tar.gz repo/x86_64/*.pkg.tar.zst`.
  - Configure `pacman.conf` in `core/archiso` to consume the custom repo.

### Verification Gate (Exit Criteria)
- `pacman -Sy --config core/archiso/airootfs/etc/pacman.conf` successfully synchronizes the `[kaze]` repository and resolves `kaze-cli` and `quickshell`.

---

## Phase 2: Universal Calamares Installer & Automated Btrfs Engine

**Objective**: Configure a reliable graphical installer with automated 5-subvolume Btrfs partitioning and pre-configured Snapper rollback snapshots.

### Milestones & Deliverables
- [ ] **M2.1: Calamares Core Configuration (`core/calamares/`)**
  - Configure `settings.conf` execution queue:
    `partition`, `mount`, `unpackfs`, `fstab`, `locale`, `keyboard`, `users`, `networkmanager`, `bootloader`, `services-systemd`, `umount`.
- [ ] **M2.2: Automated 5-Subvolume Btrfs Specification (`mount.conf`)**
  - Configure automated mounts:
    - `@` -> `/`
    - `@home` -> `/home`
    - `@snapshots` -> `/.snapshots`
    - `@var_log` -> `/var/log`
    - `@var_cache` -> `/var/cache`
  - Mount flags: `compress=zstd:3,noatime,space_cache=v2`.
- [ ] **M2.3: Snapper & Bootloader Integration**
  - Configure `snapper` root configuration template.
  - Enable `snap-pac` to take pre/post snapshots on `pacman` actions.
  - Configure `grub-btrfs` systemd daemon to auto-generate boot entries for every snapshot.
- [ ] **M2.4: First-Boot Setup App (`kaze-welcome`)**
  - Author lightweight GUI:
    - Mirror ranking via `reflector`
    - GPU driver detection (Nvidia proprietary vs open-source)
    - Snapshot status badge
  - Autostart entry installed into `/etc/xdg/autostart/kaze-welcome.desktop`.

### Verification Gate (Exit Criteria)
- Installing the OS to a virtual disk in QEMU partitions the disk into the 5 Btrfs subvolumes, installs GRUB, and takes a snapshot on the first `pacman -S` transaction.

---

## Phase 3: Flavor Implementation — Kaze Kasumi (Aesthetic Rice)

**Objective**: Port, package, and optimize the Hyprland + QuickShell + Matugen aesthetic rice into an out-of-the-box live and installed desktop.

### Milestones & Deliverables
- [ ] **M3.1: Package List Assembly (`flavors/kasumi/packages.flavor`)**
  - `hyprland`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`, `polkit-kde-agent`
  - `quickshell`, `matugen`, `awww`, `ghostty`
  - `qt5-wayland`, `qt6-wayland`, `wl-clipboard`, `grim`, `slurp`
  - Font stack: `ttf-jetbrains-mono-nerd`, `noto-fonts`, `noto-fonts-cjk`, `noto-fonts-emoji`
- [ ] **M3.2: Modular Lua Hyprland Porting**
  - Place in `flavors/kasumi/airootfs/etc/skel/.config/hypr/`:
    - `hyprland.lua`
    - `lua/settings.lua` (animations, input, gestures, dwindle layout)
    - `lua/binds.lua` (Super key ergonomics)
    - `lua/window-rules.lua` (QuickShell popups, floating rules)
    - `lua/autostart.lua` (`awww-daemon`, `quickshell -d`, `hypridle`, `polkit-kde-agent`)
    - `lua/colors.lua` (initial default palette)
- [ ] **M3.3: QuickShell Component Deployment**
  - Place in `flavors/kasumi/airootfs/etc/skel/.config/quickshell/`:
    - `shell.qml`, `qmldir`, `Theme.qml`, `colors.json`
    - `Bar.qml` (floating top/bottom bar)
    - `Dashboard.qml` (quick settings control center)
    - `Launcher.qml` (application runner)
    - `NotificationPopup.qml` (notification banner)
    - `WallpaperPicker.qml` (interactive wallpaper gallery)
- [ ] **M3.4: Matugen & Awww Live Pipeline Integration**
  - Configure `~/.config/matugen/config.toml` targeting:
    - Hyprland (`~/.config/hypr/lua/colors.lua`)
    - QuickShell (`~/.config/quickshell/colors.json`)
    - Ghostty (`~/.config/ghostty/theme`)
  - Ensure first-boot script runs initial wallpaper generation from `/usr/share/backgrounds/kaze/`.
- [ ] **M3.5: Calamares Kasumi Branding**
  - Custom dark neon theme, slides highlighting QuickShell, shortcuts, and themes.

### Verification Gate (Exit Criteria)
- Live ISO boots into a functional Hyprland session; QuickShell bar and launcher render properly; changing wallpapers via `kaze-cli wallpaper` shifts the desktop color scheme live across all apps.

---

## Phase 4: Flavor Implementation — Kaze Hayate (Performance OS)

**Objective**: Configure the low-latency gaming and compute edition with CachyOS kernel, schedulers, zram, and Calamares Netinstall DE selector.

### Milestones & Deliverables
- [ ] **M4.1: Kernel & Microarchitecture Optimization**
  - Enable CachyOS repository in `pacman.conf`.
  - Add `linux-cachyos` (primary) and `linux-zen` (fallback) to `packages.flavor`.
  - Include `linux-cachyos-headers` and `linux-zen-headers`.
- [ ] **M4.2: Performance Daemons & Sysctl Tuning**
  - Add `ananicy-cpp`, `cachyos-ananicy-rules`, `zram-generator`, `gamemode`, `lib32-gamemode`.
  - Install `/etc/sysctl.d/99-kaze-performance.conf`:
    - Tuned memory flushing (`dirty_bytes`, `swappiness=10`).
    - Lower scheduler slice (`kernel.sched_cfs_bandwidth_slice_us=3000`).
  - Configure `/etc/systemd/zram-generator.conf`:
    - `zram0`: `compression-algorithm = zstd`, `zram-fraction = 1.0`.
- [ ] **M4.3: Gaming Stack & Driver Integration**
  - Include Wine/Proton prerequisites: `wine-staging`, `winetricks`, `vulkan-tools`, `dxvk-bin`.
  - GPU hardware stacks: `vulkan-radeon`, `vulkan-intel`, `nvidia-utils` (driver installer wizard).
- [ ] **M4.4: Calamares Netinstall Module (The CachyOS Selector)**
  - Configure `netinstall.yaml` with choices:
    - `KDE Plasma 6 (Tuned Gaming Rice)` [Default]
    - `Hyprland (Performance Profile)`
    - `GNOME 46 (Wayland)`
    - `Headless / Minimal Base`

### Verification Gate (Exit Criteria)
- System boots with `uname -r` returning `linux-cachyos`; `ananicy-cpp` and `zram-generator` are active (`swapon` shows `/dev/zram0` with zstd); `gamemoderun` successfully sets the performance governor.

---

## Phase 5: Flavor Implementation — Kaze Nagomi (Daily Driver)

**Objective**: Configure the reliable, accessible daily workstation featuring KDE Plasma 6, GNOME installer fallback, Discover/Flatpak, Pamac, and battery optimization.

### Milestones & Deliverables
- [ ] **M5.1: Desktop Environment Stack (`packages.flavor`)**
  - `plasma-meta`, `plasma-wayland-session`, `kde-applications-meta`, `sddm`
  - Optional GNOME package group in Calamares netinstall: `gnome`, `gnome-extra`, `gdm`
- [ ] **M5.2: Software Center & Flatpak Setup**
  - `discover`, `packagekit-qt6`, `flatpak`
  - Automated post-install script adding Flathub repository:
    `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`
  - `pamac-aur` or `bauh` bundled for advanced AUR package browsing.
- [ ] **M5.3: Laptop & Power Optimization**
  - Enable `power-profiles-daemon` for one-click battery saving in KDE system tray.
  - Video hardware acceleration: `intel-media-driver`, `libva-mesa-driver`.
  - Audio & Peripherals: `pipewire-alsa`, `pipewire-jack`, `bluez`, `bluez-utils`, `cups`, `system-config-printer`.

### Verification Gate (Exit Criteria)
- Boots into SDDM and logs in smoothly to KDE Plasma 6 Wayland; Flathub apps are discoverable and installable through the Discover GUI without terminal interaction.

---

## Phase 6: GitHub Actions CI/CD Pipeline

**Objective**: Fully automate package compilation and bootable ISO image releases via GitHub Actions.

### Milestones & Deliverables
- [ ] **M6.1: Package Build Pipeline (`.github/workflows/build-packages.yml`)**
  - Triggers on git push to `pkgs/**`.
  - Spawns Arch Linux Docker container.
  - Builds all modified PKGBUILDs, runs `repo-add`, and pushes updated `.pkg.tar.zst` and `kaze.db.tar.gz` to GitHub Releases.
- [ ] **M6.2: ISO Build Pipeline (`.github/workflows/build-iso.yml`)**
  - Triggers on release tags (e.g. `v1.0.0-kasumi`, `v1.0.0-hayate`).
  - Executes `easimon/maximize-build-space` action to reclaim 30+ GB runner disk space.
  - Runs `./build.sh --flavor <flavor>` inside privileged Arch container with `/dev/loop-control`.
  - Uploads the resulting `.iso` and SHA256 checksum to GitHub Releases.

### Verification Gate (Exit Criteria)
- Pushing a test release tag successfully completes the GitHub Action and attaches a bootable ISO to the release.

---

## Phase 7: Verification & Final Polishing

**Objective**: Comprehensive hardware and virtualization testing of all three distributions.

### Milestones & Deliverables
- [ ] **M7.1: Virtual Machine Matrix Testing**
  - Test UEFI boot, BIOS/Legacy boot, and Secure Boot behavior.
  - Test resolution auto-detection in QEMU, VirtualBox, and VMware.
- [ ] **M7.2: Bare-Metal Testing Matrix**
  - Test on Intel + Nvidia laptop (optimus switching).
  - Test on all-AMD desktop (AMDGPU + FreeSync).
  - Test on low-spec laptop (verifying battery profile and idle RAM).
- [ ] **M7.3: Disaster Recovery Simulation**
  - Deliberately break system files (`sudo rm -rf /usr/lib/modules`) and execute a Snapper rollback from the GRUB boot menu to prove zero-data-loss recovery.
