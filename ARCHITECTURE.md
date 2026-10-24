# KAZE OS: SYSTEM ARCHITECTURE & TECHNICAL SPECIFICATION
**Umbrella Project:** Kaze OS (風)  
**Document Classification:** Technical Architecture Document (TAD)  
**Version:** 1.0.0  

---

## 1. Architectural Philosophy

Kaze OS is built upon three foundational engineering principles:

1. **Separation of Concerns through Modular Flavors**: No single operating system configuration can simultaneously maximize competitive esports gaming, minimalist tiling ricing, and traditional beginner-friendly office productivity without bloat or compromise. Kaze OS isolates these distinct workloads into three tailored flavors: **Hayate** (Performance), **Kasumi** (Aesthetic Wayland), and **Nagomi** (Daily Driver).
2. **Monorepo Engine with Overlay Composition**: All flavors share a unified, validated core (`core/archiso` and `core/calamares`). Flavors are non-destructive overlays merged dynamically at build time. Bug fixes in base networking, installer logic, or storage subvolumes automatically propagate to all three operating systems.
3. **Resilience by Design (The "Unbreakable Arch" Model)**: Rolling-release distributions must guarantee system recoverability. By enforcing a 5-subvolume Btrfs topology with automated pre/post pacman snapshots (`snap-pac` + `grub-btrfs`), any broken update or misconfiguration can be rolled back from the bootloader in under 30 seconds without touching user files in `/home`.

---

## 2. Monorepo Layering & Build Engine

The repository uses a three-tier layered architecture:

```
┌────────────────────────────────────────────────────────────────────────┐
│                          TIER 3: FLAVOR OVERLAYS                       │
│     flavors/hayate/            flavors/kasumi/        flavors/nagomi/  │
│  (Kernel & Latency)          (Hyprland & QML)        (Plasma 6 & Store)│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Overlays onto
┌───────────────────────────────────▼────────────────────────────────────┐
│                          TIER 2: SHARED CORE ENGINE                    │
│      core/archiso/             core/calamares/       core/packages.common│
│  (Base bootloader/root)     (5-subvolume Btrfs)     (Network, audio, XDG)│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Consumes
┌───────────────────────────────────▼────────────────────────────────────┐
│                    TIER 1: PACKAGE DELIVERY ECOSYSTEM                  │
│        Official Arch Repos        CachyOS Repos        Custom Kaze Repo │
│     (Core, Extra, Multilib)      (Kernel & v3)       (CLI, Shell, Themes)│
└────────────────────────────────────────────────────────────────────────┘
```

### The Dynamic Merge Process (`build.sh`)
When `./build.sh --flavor <flavor>` is executed, the build controller performs an ephemeral profile synthesis:

```
[core/archiso] ──────────┐
                         ├─► [work/profile/airootfs] ──► mkarchiso ──► [out/*.iso]
[flavors/<flavor>/airootfs] ─┘
```

1. **Directory Mirroring**: `core/archiso` is copied to a transient workspace `work/profile/`.
2. **Package Concatenation**: `core/packages.common` is combined with `flavors/<flavor>/packages.flavor` to generate `work/profile/packages.x86_64`. Duplicate packages are deduplicated automatically.
3. **Airootfs Overlay**: `flavors/<flavor>/airootfs/` is copied on top of `work/profile/airootfs/` using `rsync -aK`. Any flavor-specific configuration overrides the default while preserving untouched core files.
4. **Calamares Branding Injection**: The installer branding assets corresponding to the flavor are written into `/etc/calamares/branding/kaze-<flavor>/`.
5. **Image Synthesis**: `mkarchiso` executes inside a loopback container, generates the compressed SquashFS filesystem, builds UEFI/BIOS bootloaders, and produces the finalized `.iso` image in `out/`.

---

## 3. Storage & Subvolume Architecture

All Kaze OS flavors default to Btrfs formatted with Zstandard level 3 compression (`compress=zstd:3`).

### Subvolume Layout Topology

```
Physical Disk Partition (Btrfs Root)
│
├── Subvolume: @                Mounted at: /
│   ├── /usr
│   ├── /etc
│   └── /var (excluding log/cache)
│   (Target of automated Snapper snapshots and system rollbacks)
│
├── Subvolume: @home            Mounted at: /home
│   ├── /home/user/Documents
│   ├── /home/user/Downloads
│   └── /home/user/.config
│   (STRICTLY ISOLATED: Never touched during a system rollback)
│
├── Subvolume: @snapshots       Mounted at: /.snapshots
│   └── Snapper snapshot metadata and read-only tree snapshots
│
├── Subvolume: @var_log         Mounted at: /var/log
│   └── Preserves systemd journal and boot logs across rollbacks for debugging
│
└── Subvolume: @var_cache       Mounted at: /var/cache
    └── Preserves pacman package cache (/var/cache/pacman/pkg)
```

### Automated Rollback Execution Flow

```
User runs: pacman -Syu
       │
       ▼
[snap-pac Pre-Hook] ──► Takes read-only snapshot: "@_snapshot_pre"
       │
       ▼
[Pacman Transaction] ──► Installs packages (Kernel, GPU driver, systemd)
       │
       ▼
[snap-pac Post-Hook] ──► Takes read-only snapshot: "@_snapshot_post"
       │
       ▼
[grub-btrfs Daemon] ──► Regenerates bootloader menu with snapshot timestamps
       │
   (If boot fails)
       │
       ▼
User boots into: "Arch Linux Snapshots -> Yesterday 22:30 (Pre-update)"
       │
       ▼
User runs: `sudo snapper rollback`
       │
       ▼
System state is restored instantly; `/home` files remain untouched.
```

---

## 4. Flavor Architecture Deep-Dives

---

### 4.1 Kaze Hayate (Performance & Gaming)

```
                    ┌──────────────────────────────┐
                    │      Active Fullscreen Game  │
                    │      (Steam / Lutris / Wine) │
                    └──────────────┬───────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                                         ▼
   ┌──────────────────────┐                  ┌──────────────────────┐
   │     GameMode API     │                  │     ananicy-cpp      │
   │  - Sets CPU Governor │                  │  - Prioritizes Game  │
   │    to "performance"  │                  │    SCHED_ISO / RR    │
   │  - Boosts GPU Clocks │                  │  - Throttles Browser │
   │  - Inhibits Screensaver                 │    and Background IO │
   └──────────────────────┘                  └──────────────────────┘
              │                                         │
              └────────────────────┬────────────────────┘
                                   │
                                   ▼
                 ┌────────────────────────────────────┐
                 │        linux-cachyos Kernel        │
                 │   - BORE (Burst-Oriented Scheduler)│
                 │   - MGLRU Memory Reclamation       │
                 │   - x86-64-v3 Compiled Binaries    │
                 │   - zram-generator (zstd in RAM)   │
                 └────────────────────────────────────┘
```

#### Key Technical Subsystems:
1. **BORE Scheduler**: The Burst-Oriented Response Enhancer converts CPU scheduling priorities dynamically. Tasks with short, bursty CPU consumption (such as game physics loops, input handling, and audio frame dispatch) receive immediate scheduling preemption over continuous computational batch workloads.
2. **MGLRU (Multi-Gen LRU)**: Optimizes page reclamation algorithms, reducing CPU spikes under high memory pressure.
3. **ZRAM Architecture**: `/etc/systemd/zram-generator.conf` establishes a zstandard-compressed RAM swap pool with zero disk swap penalty, eliminating micro-stutters when games approach system RAM limits.

---

### 4.2 Kaze Kasumi (Aesthetic Wayland Rice)

```
                     ┌───────────────────────────┐
                     │    User selects image     │
                     │  (or kaze-cli wallpaper)  │
                     └─────────────┬─────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
         ┌─────────────────────┐       ┌─────────────────────┐
         │     awww Engine     │       │    Matugen Daemon   │
         │  - 144Hz Smooth     │       │  - Extracts Material│
         │    Wipe Transition  │       │    You color tokens │
         └─────────────────────┘       └──────────┬──────────┘
                                                  │
                 ┌────────────────────────────────┼────────────────────────────────┐
                 ▼                                ▼                                ▼
      ┌─────────────────────┐          ┌─────────────────────┐          ┌─────────────────────┐
      │  Hyprland Lua Pipe  │          │    QuickShell IPC   │          │   Ghostty Terminal  │
      │  Writes:            │          │  Writes:            │          │  Writes:            │
      │  hypr/lua/colors.lua│          │  quickshell/        │          │  ~/.config/ghostty/ │
      │  Executes:          │          │  colors.json        │          │  theme              │
      │  `hyprctl reload`   │          │  Executes:          │          │  Live reloads       │
      │                     │          │  `quickshell ipc    │          │  GPU shader colors  │
      │                     │          │   call theme reload`│          │                     │
      └─────────────────────┘          └─────────────────────┘          └─────────────────────┘
```

#### Key Technical Subsystems:
1. **Modular Lua Configuration**: Hyprland configuration is executed in Lua using clean modules (`settings.lua`, `binds.lua`, `window-rules.lua`, `autostart.lua`). This eliminates fragile, monolithic `hyprland.conf` files and allows programmatic scripting of rules and binds.
2. **QuickShell (QtQuick / QML)**: Rather than separate disparate daemons for the bar, notification daemon, control center, and app runner, QuickShell unifies all desktop UI components into a single hardware-accelerated process.
3. **Dynamic Theming Bus**: Matugen acts as the central color authority, parsing wallpaper RGB values and projecting them across three application layers: Window Manager borders (Hyprland), System Shell (QuickShell), and Terminal Emulator (Ghostty).

---

### 4.3 Kaze Nagomi (Daily Driver Workstation)

```
                  ┌────────────────────────────────────────┐
                  │          KDE Plasma 6 (Wayland)        │
                  │   - Native Fractional Scaling (KMS)    │
                  │   - Night Light & Color Management     │
                  │   - Power-Profiles-Daemon Integration  │
                  └───────────────────┬────────────────────┘
                                      │
                 ┌────────────────────┴────────────────────┐
                 │                                         │
                 ▼                                         ▼
      ┌──────────────────────┐                  ┌──────────────────────┐
      │   Discover Software  │                  │      Pamac GUI       │
      │        Center        │                  │   - Arch Official    │
      │  - Flathub Out-of-   │                  │     Repositories     │
      │    the-box           │                  │   - AUR Package      │
      │  - Sandboxed Desktop │                  │     Inspection       │
      │    Applications      │                  │   - Pacman Backend   │
      └──────────────────────┘                  └──────────────────────┘
```

#### Key Technical Subsystems:
1. **KDE Plasma 6 on Wayland**: Modern display stack providing tear-free rendering, per-monitor fractional scaling, and hardware touchpad gestures out of the box.
2. **Dual-Tier Software Delivery**: Non-technical users interact exclusively with Discover and sandboxed Flatpaks from Flathub. Advanced users retain access to Pamac for system-level Arch Linux and AUR software management.
3. **Integrated Power Management**: `power-profiles-daemon` connects directly into Plasma's battery widget, allowing instantaneous hardware switching between "Power Saver", "Balanced", and "Performance" states without user terminal commands.

---

## 5. Custom Package Repository & Distribution Topology

Custom packages (`kaze-cli`, `kaze-branding`, `quickshell`, `matugen`, `awww`) are compiled and maintained via a dedicated repository structure:

```
[GitHub Repository: arch-distro/pkgs]
                 │
                 ▼ (git push / release tag)
[.github/workflows/build-packages.yml]
                 │
                 ├── Spawns clean Arch Linux build chroot
                 ├── Compiles PKGBUILDs via `makepkg -s`
                 ├── Generates pacman repo database: `repo-add kaze.db.tar.gz`
                 │
                 ▼
[GitHub Releases / Pages CDN]
   URL: https://kaze-os.github.io/repo/x86_64/
   ├── kaze.db.tar.gz
   ├── kaze.files.tar.gz
   ├── kaze-cli-1.0.0-1-any.pkg.tar.zst
   ├── kaze-branding-1.0.0-1-any.pkg.tar.zst
   ├── quickshell-git-latest-x86_64.pkg.tar.zst
   └── awww-bin-latest-x86_64.pkg.tar.zst
```

### Pacman Integration (`pacman.conf`)
Every Kaze OS installation includes the following repository stanza above standard Arch repositories:

```ini
[kaze]
SigLevel = Optional TrustAll
Server = https://kaze-os.github.io/repo/$arch
```
