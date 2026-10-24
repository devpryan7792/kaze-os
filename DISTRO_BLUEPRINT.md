# KAZE OS: MASTER ARCHITECTURAL BLUEPRINT & SPECIFICATION
**Version:** 1.0.0  
**Project Umbrella:** Kaze OS (風 - *Motion, Flow, and Power*)  
**Base Distribution:** Arch Linux (Rolling Release)  
**Author / Maintainer:** devpryan7792  

---

## 1. Executive Summary & Brand Identity

Kaze OS is an ecosystem of three specialized, independent Arch-based Linux distributions engineered from a unified, modular build engine. Rather than attempting a single bloated "jack-of-all-trades" operating system, Kaze OS splits into three hyper-focused flavors sharing a common resilient foundation:

```
                          ┌───────────────────────────┐
                          │   Kaze OS Core Engine     │
                          │ (archiso + btrfs + repo)  │
                          └─────────────┬─────────────┘
                                        │
         ┌──────────────────────────────┼──────────────────────────────┐
         ▼                              ▼                              ▼
 ┌───────────────┐              ┌───────────────┐              ┌───────────────┐
 │  KAZE HAYATE  │              │  KAZE KASUMI  │              │  KAZE NAGOMI  │
 │ (疾風 - Gale) │              │  (霞 - Mist)  │              │ (和 - Harmony)│
 │  Performance  │              │Aesthetic Rice │              │ Daily Driver  │
 └───────────────┘              └───────────────┘              └───────────────┘
```

1. **Kaze Hayate (疾風 - Swift Gale)**: Pure performance, gaming, and low-latency workloads. Features custom patched kernels, real-time interactive CPU schedulers, memory tuning daemons, and low-latency display pipelines.
2. **Kaze Kasumi (霞 - Elegant Mist)**: Design purist & ricing workstation. Built around Hyprland (configured via modular Lua), QuickShell (QML/QtQuick), Matugen dynamic Material You palette extraction, 144Hz `awww` transitions, and the bespoke `kaze-cli` system utility.
3. **Kaze Nagomi (和 - Serene Harmony)**: Polished, rock-solid daily driver. Ships with modern KDE Plasma 6 (with GNOME installer option), out-of-the-box Flatpak Discover store + Pamac AUR manager, automatic Btrfs/Snapper boot recovery, and laptop power optimization.

---

## 2. Monorepo Codebase & Directory Structure

All three operating systems are built from a single repository located at `/home/pryan/code/arch-distro`. This monorepo architecture prevents code drift, unifies bug fixes, and generates distinct, standalone bootable ISO images.

```text
arch-distro/
├── DISTRO_BLUEPRINT.md                  # This master specification document
├── build.sh                             # Main build controller script
│
├── core/                                # Shared foundation across all 3 flavors
│   ├── archiso/                         # Base archiso configuration
│   │   ├── airootfs/                    # Common filesystem root overlay
│   │   │   ├── etc/
│   │   │   │   ├── pacman.conf          # Base pacman config with custom Kaze repo
│   │   │   │   ├── locale.gen           # Default locales
│   │   │   │   └── systemd/             # Core systemd services (NetworkManager, etc.)
│   │   │   └── root/                    # Live environment root files
│   │   ├── efiboot/                     # UEFI bootloader files
│   │   ├── syslinux/                    # BIOS bootloader files
│   │   └── profiledef.sh                # Base archiso profile definition
│   │
│   ├── calamares/                       # Base installer modules
│   │   ├── modules/                     # Partitioning, btrfs, users, locale, finish
│   │   └── settings.conf                # Common Calamares execution sequence
│   │
│   ├── packages.common                  # Packages common to all ISOs (base, drivers, audio)
│   └── scripts/                         # Helper scripts for ISO assembly and validation
│
├── flavors/                             # Flavor-specific overlays
│   ├── hayate/                          # Flavor 1: Performance OS
│   │   ├── packages.flavor              # linux-cachyos, ananicy-cpp, zram-generator, gamemode
│   │   ├── airootfs/                    # /etc/sysctl.d/99-performance.conf, ananicy rules
│   │   └── calamares/                   # Hayate branding, netinstall.yaml (DE selection)
│   │
│   ├── kasumi/                          # Flavor 2: Aesthetic Rice OS
│   │   ├── packages.flavor              # hyprland, quickshell, awww, matugen, ghostty, hyprlock
│   │   ├── airootfs/
│   │   │   ├── etc/skel/.config/        # Default user configs (hypr, quickshell, matugen)
│   │   │   └── usr/share/backgrounds/   # Curated Kaze wallpaper suite
│   │   └── calamares/                   # Kasumi branding & minimalist neon slideshow
│   │
│   └── nagomi/                          # Flavor 3: Daily Driver OS
│       ├── packages.flavor              # plasma-desktop, discover, flatpak, pamac, power-profiles
│       ├── airootfs/                    # Snapper configs, default themes, polkit rules
│       └── calamares/                   # Nagomi welcoming branding & DE toggle
│
├── pkgs/                                # PKGBUILDs for custom packages
│   ├── kaze-cli/                        # The unified command-line management tool
│   ├── kaze-welcome/                    # First-boot interactive GUI setup wizard
│   ├── kaze-branding/                   # Wallpapers, icons, and Plymouth boot splash
│   ├── quickshell-git/                  # Upstream PKGBUILD for QuickShell
│   └── awww-bin/                        # Upstream PKGBUILD for awww wallpaper daemon
│
├── repo/                                # Local package repository cache & repo-add scripts
└── .github/
    └── workflows/
        ├── build-packages.yml           # CI/CD: Builds PKGBUILDs and deploys to GitHub Releases
        └── build-iso.yml                # CI/CD: Compiles ISOs using Docker/archiso
```

---

## 3. The Build Engine (`build.sh`)

The build engine combines `core/` and the target `flavors/<flavor>/` directory into a temporary working profile and executes `mkarchiso`.

### Build Engine Workflow:
1. **Pre-flight Check**: Validates that `archiso`, `pacman`, and root privileges (`sudo`) are present.
2. **Profile Assembly**:
   - Copies `core/archiso` to `work/profile/`.
   - Merges `core/packages.common` and `flavors/<flavor>/packages.flavor` into `work/profile/packages.x86_64`.
   - Overlays `flavors/<flavor>/airootfs/` on top of `work/profile/airootfs/`.
   - Copies `flavors/<flavor>/calamares/` branding and settings into the target filesystem.
3. **Pacman Keyring & Custom Repo Injection**: Appends the Kaze OS custom binary repository to `pacman.conf` in the build root.
4. **Execution**: Runs `mkarchiso -v -w work/tmp -o out/ work/profile`.
5. **Checksum & Output**: Generates `out/kaze-<flavor>-<version>-x86_64.iso` and `out/kaze-<flavor>-<version>-x86_64.iso.sha256`.

---

## 4. Flavor Deep-Dive 1: Kaze Hayate (Performance OS)

### 4.1 Target Audience & Objective
Gamers, 3D renderers, and high-performance computing users requiring minimum input latency, stable 1% low frame-rates, and maximum hardware bandwidth.

### 4.2 Kernel & Architecture
- **Primary Kernel**: `linux-cachyos` (pre-compiled with `-O3`, BORE scheduler, and MGLRU enabled).
- **Secondary Fallback Kernel**: `linux-zen` (official Arch fallback).
- **Target Microarchitecture**: `x86-64-v3` optimized package repository enabled by default (with auto-detection script to fall back to `x86-64` generic if an older CPU is detected).

### 4.3 Low-Latency & Memory Stack
- **`ananicy-cpp`**: Active daemon with community game rules. Dynamically boosts process priority, SCHED_RR/SCHED_ISO policies, and I/O bandwidth for active games and audio renderers while throttling background tasks.
- **`zram-generator`**:
  - Algorithm: `zstd`
  - RAM Allocation: `zram-fraction = 1.0` (equal to total RAM)
  - Swap Priority: `32767`
- **`gamemode`**: Automatically sets CPU frequency governor to `performance`, triggers GPU clock boosts, disables compositor composition, and assigns elevated scheduler niceness.
- **Kernel Sysctl Optimizations (`/etc/sysctl.d/99-kaze-performance.conf`)**:
  ```ini
  vm.swappiness = 10
  vm.vfs_cache_pressure = 50
  vm.dirty_bytes = 268435456
  vm.dirty_background_bytes = 134217728
  fs.file-max = 2097152
  kernel.sched_cfs_bandwidth_slice_us = 3000
  ```

### 4.4 Desktop & Installer Experience
- **Live ISO Session**: Tuned KDE Plasma 6 (Wayland) with blur disabled by default for maximum input responsiveness and native VRR (Variable Refresh Rate / FreeSync / G-Sync) support.
- **CachyOS-Style Netinstall Selector**:
  During Calamares installation, users can select their preferred interface:
  - `[x] KDE Plasma 6 (Tuned Gaming Profile)` [Default]
  - `[ ] Hyprland (Performance Rice)`
  - `[ ] GNOME 46 (Wayland)`
  - `[ ] Minimal Terminal (No Desktop)`

---

## 5. Flavor Deep-Dive 2: Kaze Kasumi (Aesthetic Rice OS)

### 5.1 Target Audience & Objective
Ricing enthusiasts, developers, and visual designers who want an uncompromising modern Wayland experience featuring fluid animations, dynamic color harmony, and hardware-accelerated widgets.

### 5.2 Theming & Shell Architecture (Dual-Tier Strategy)
To ensure 100% build reliability and eliminate phantom dependency failures, Kasumi employs a **Dual-Tier UI Strategy**:
- **Tier 1 (Guaranteed Official Core)**: Available directly from official Arch repositories (`[core]`, `[extra]`):
  - **Compositor**: `hyprland` (modular config structure in `~/.config/hypr/`).
  - **Terminal**: `kitty` (primary official GPU-accelerated terminal) with fallback keybindings.
  - **Status Bar**: `waybar` (fully themed, reliable, CSS-styled Wayland bar).
  - **Launcher**: `fuzzel` (lightning-fast, blurred Wayland app finder).
  - **Wallpaper Daemon**: `hyprpaper` / `swaybg`.
  - **Screen Lock & Idle**: `hyprlock` + `hypridle`.

- **Tier 2 (Enhanced Rice Extensions)**: Packaged via `pkgs/` into `repo/`:
  - **Desktop Shell & Widgets**: `quickshell` (QtQuick/QML modular widgets for bar, launcher, and control center).
  - **Dynamic Theming**: `matugen` (Material You dynamic palette generator extracting tokens from wallpapers).
  - **Wallpaper Daemon**: `awww` (144Hz animated wipe transitions).
  - **Terminal**: `ghostty` (optional terminal alternative).

When Tier 2 packages are built in `repo/x86_64`, they seamlessly enhance the desktop experience; if absent, Tier 1 provides an immediate, flawlessly functional, beautiful Wayland environment with zero black screens or missing binary crashes.

### 5.3 Curated Asset Suite
- Bundled into `/usr/share/backgrounds/kaze/`:
  - 10 curated high-resolution minimalist, cyberpunk, and Japanese-aesthetic wallpapers.
  - Fully pre-tested to ensure perfect Matugen contrast ratios across light and dark elements.

### 5.4 The `kaze-cli` Management Utility
A custom Python/Bash binary placed in `/usr/bin/kaze-cli`:
- `kaze-cli wallpaper [random | /path/to/img]`: Updates wallpaper and triggers live Matugen reload.
- `kaze-cli scheme [tonal-spot | vibrant | expressive | neutral]`: Switches color mood.
- `kaze-cli sync`: Fetches official config updates from the Kaze repository, prompting the user before merging and automatically saving a backup to `~/.config/hypr.backup-<timestamp>`.
- `kaze-cli doctor`: Diagnostic tool that verifies Hyprland plugins, audio servers, GPU drivers, and QuickShell IPC status.

---

## 6. Flavor Deep-Dive 3: Kaze Nagomi (Daily Driver OS)

### 6.1 Target Audience & Objective
General desktop users, students, software engineers, and newcomers migrating to Arch who need an intuitive, reliable, and unbreakable operating system.

### 6.2 Desktop & Usability Stack
- **Default Desktop**: **KDE Plasma 6 (Wayland)** with an option in the installer to select **GNOME**.
- **Software Centers**:
  - **Discover + Flathub**: Primary safe graphical store for sandboxed everyday applications (Spotify, Steam, Discord, LibreOffice, Chrome).
  - **Pamac GUI**: Advanced package manager for full Arch repositories and AUR packages.
- **Power & Hardware Optimization**:
  - `power-profiles-daemon`: Integrated with desktop settings for instant "Power Saver", "Balanced", and "Performance" modes.
  - Full Bluetooth audio codecs (`libfreeaptx`, `ldacBT`, `pipewire-pulse`).
  - Network and printer discovery: `avahi-daemon` and `cups` pre-configured.

---

## 7. Storage, Filesystem & Automated Recovery (All Flavors)

### 7.1 Btrfs Subvolume Topology
All three flavors default to **Btrfs** with a dedicated subvolume layout engineered to make system recovery 100% safe without risking user documents:

| Subvolume | Mount Point | Purpose | Snapshot Behavior |
| :--- | :--- | :--- | :--- |
| `@` | `/` | System root files & binaries | **Snapshotted & Rolled Back** |
| `@home` | `/home` | User data, downloads, documents | **Excluded from rollback** (Preserved) |
| `@snapshots` | `/.snapshots`| Snapper snapshot metadata | Excluded from rollback |
| `@var_log` | `/var/log` | System logs | Excluded from rollback (Preserved) |
| `@var_cache` | `/var/cache` | Pacman package cache | Excluded from rollback (Preserved) |

### 7.2 Automated Snapper Pipeline
1. **Trigger**: `snap-pac` intercepts every `pacman` transaction (install, upgrade, remove).
2. **Pre-Snapshot**: A read-only snapshot is taken immediately before packages change.
3. **Post-Snapshot**: A second snapshot is taken after completion.
4. **Bootloader Integration**: `grub-btrfs` / `systemd-boot` automatically populates the boot menu with the latest 10 snapshots.
5. **Rollback**: If a driver or update breaks boot, the user selects the previous snapshot in the boot menu, boots in, and runs `snapper rollback`.

---

## 8. Calamares Installer & First-Boot Wizard

### 8.1 Installer Architecture
A unified Calamares codebase with dynamic branding modules:
- `/etc/calamares/branding/kaze-hayate/`
- `/etc/calamares/branding/kaze-kasumi/`
- `/etc/calamares/branding/kaze-nagomi/`

Each branding set includes custom color themes, vector logos, and targeted feature slideshows during the installation progress bar.

### 8.2 First-Boot Setup App (`kaze-welcome`)
A modern, lightweight GUI application that opens on first login offering:
1. **Rank Mirrors**: Runs `reflector` in the background to ensure fastest local downloads.
2. **GPU Driver Assistant**: Detects Nvidia / AMD / Intel hardware and confirms optimal driver packages.
3. **Essential Software Bundles**: One-click toggles for gaming tools, developer suites, or office tools.
4. **Snapshot Status**: Confirms Btrfs/Snapper protection is active.

---

## 9. Custom Package Repository & CI/CD Pipeline

### 9.1 Repository Hosting via GitHub Releases + Pages
- **URL**: `https://kaze-os.github.io/repo/x86_64/`
- **Database**: `kaze.db.tar.gz` and `kaze.files.tar.gz`
- Hosted entirely on GitHub Releases with a GitHub Pages index.

### 9.2 Custom PKGBUILD Packages
1. `kaze-cli`: Distro shell utility.
2. `kaze-welcome`: First-boot setup GUI.
3. `kaze-branding`: Wallpapers, GTK/Qt theme defaults, Plymouth boot splash.
4. `quickshell`: Wayland desktop shell compiled from source.
5. `awww`: Rust-based Wayland wallpaper daemon.
6. `matugen-bin`: Material You dynamic color generator.

### 9.3 CI/CD Workflows (`.github/workflows/`)
- `build-packages.yml`: Triggers on changes to `pkgs/`. Spins up an Arch Linux container, compiles each PKGBUILD with `makepkg -s`, signs packages, updates the repo database with `repo-add`, and pushes to the repository release.
- `build-iso.yml`:
  - Uses `easimon/maximize-build-space` to strip unnecessary tools from GitHub Actions runners to provide 30+ GB of free disk space.
  - Builds the requested flavor ISO via Docker `archiso`.
  - Publishes the final `.iso` image and SHA256 checksum to GitHub Releases.

---

## 10. Step-by-Step Implementation Roadmap

When proceeding to execution, any developer or autonomous agent must execute these milestones in exact sequence:

### Milestone 1: Workspace Skeleton & Core Archiso Base
1. Initialize the monorepo directory layout: `core/`, `flavors/hayate`, `flavors/kasumi`, `flavors/nagomi`, `pkgs/`.
2. Extract Arch's standard `releng` profile into `core/archiso/`.
3. Create `core/packages.common` with base packages: `base`, `linux-firmware`, `networkmanager`, `pipewire`, `btrfs-progs`, `sudo`, `git`.
4. Create the core `build.sh` script with CLI arguments (`--flavor`, `--clean`, `--output`).

### Milestone 2: Custom Package Repository & PKGBUILDs
1. Author PKGBUILDs in `pkgs/` for `kaze-cli`, `kaze-branding`, `awww`, and `matugen`.
2. Set up local packaging script `repo/update-repo.sh` to generate `kaze.db.tar.gz`.
3. Add the custom repository block to `core/archiso/airootfs/etc/pacman.conf`.

### Milestone 3: Calamares Installer & Btrfs Subvolume Configuration
1. Configure Calamares `modules/mount.conf` and `partition.conf` with the 5 Btrfs subvolumes (`@`, `@home`, `@snapshots`, `@var_log`, `@var_cache`).
2. Build Calamares branding directories for `kaze-hayate`, `kaze-kasumi`, and `kaze-nagomi`.
3. Configure `snap-pac` and `grub-btrfs` hooks in `core/archiso/airootfs`.

### Milestone 4: Implement Flavor 1 — Kaze Hayate
1. Add `linux-cachyos`, `ananicy-cpp`, `zram-generator`, and `gamemode` to `flavors/hayate/packages.flavor`.
2. Add sysctl performance rules to `flavors/hayate/airootfs/etc/sysctl.d/`.
3. Configure KDE Plasma gaming session defaults and the Calamares Netinstall desktop selector.

### Milestone 5: Implement Flavor 2 — Kaze Kasumi
1. Add `hyprland`, `quickshell`, `awww`, `matugen`, `ghostty`, `hyprlock` to `flavors/kasumi/packages.flavor`.
2. Port and adapt the Lua Hyprland configurations into `flavors/kasumi/airootfs/etc/skel/.config/hypr/`.
3. Port the QuickShell components (`Bar.qml`, `Dashboard.qml`, `Launcher.qml`) into `flavors/kasumi/airootfs/etc/skel/.config/quickshell/`.
4. Bundle curated wallpapers into `flavors/kasumi/airootfs/usr/share/backgrounds/kaze/`.
5. Implement and package `kaze-cli` (`wallpaper`, `scheme`, `sync`, `doctor`).

### Milestone 6: Implement Flavor 3 — Kaze Nagomi
1. Add `plasma-desktop`, `discover`, `flatpak`, `pamac-aur`, and `power-profiles-daemon` to `flavors/nagomi/packages.flavor`.
2. Configure GNOME alternative package list in Calamares.
3. Configure default clean wallpaper, theme, and first-boot autostart for `kaze-welcome`.

### Milestone 7: ISO Compilation & Verification
1. Test-compile each flavor using `./build.sh --flavor <name>`.
2. Boot test ISOs in QEMU / KVM to verify live session startup, network detection, and Calamares installer execution.
3. Verify that the installed system reboots cleanly, mounts Btrfs subvolumes properly, and takes automatic Snapper snapshots on package transactions.
