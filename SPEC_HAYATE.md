# FLAVOR SPECIFICATION: KAZE HAYATE (疾風)
**Category:** Low-Latency Performance & Esports Gaming  
**Philosophy:** Maximize computing throughput, eliminate frame-time jitter, minimize input latency, and optimize hardware scheduling.  
**Default Kernel:** `linux-cachyos` (with `linux-zen` fallback)  
**Desktop Environment:** Tuned KDE Plasma 6 Wayland (with Calamares Netinstall DE selector)  

---

## 1. Kernel & Microarchitecture Optimization

Kaze Hayate integrates the CachyOS pre-compiled repository to leverage custom kernel optimizations and architecture-specific instruction sets.

### 1.1 The Kernel Stack
- **`linux-cachyos`**: Compiled with `-O3`, BORE (Burst-Oriented Response Enhancer) CPU scheduler, tick rate 1000Hz, and MGLRU enabled.
- **`linux-cachyos-headers`**: Header files for out-of-tree modules (e.g. DKMS Nvidia drivers, v4l2loopback).
- **`linux-zen`**: Official Arch enthusiast kernel included in bootloader as a reliable fallback.

### 1.2 Microarchitecture Optimization (`x86-64-v3`)
Kaze Hayate configures the CachyOS `v3` repository mirror when running on compatible modern CPUs (Intel Haswell / AMD Zen 1 or newer), yielding 5% to 15% throughput improvements on mathematical and graphical operations:
```ini
# /etc/pacman.conf (Hayate)
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
```

---

## 2. Memory & Real-Time Priority Daemons

### 2.1 Ananicy-CPP (`ananicy-cpp`)
Ananicy-cpp is enabled as a background systemd service (`systemctl enable ananicy-cpp.service`). It applies real-time process niceness and I/O scheduling:
- Active games (`cs2`, `dota2`, `steam_app_*`, `wine64-preloader`) are promoted to highest CPU priority with `SCHED_ISO` or `SCHED_RR` real-time scheduling.
- Background daemons (package managers, compilers, indexing services) are automatically reniced to low priority to prevent frame stutters.

### 2.2 ZRAM Memory Architecture (`/etc/systemd/zram-generator.conf`)
Disk swapping is disabled in favor of dynamic in-RAM compressed swap:
```ini
[zram0]
zram-size = min(ram, 32768)
compression-algorithm = zstd
swap-priority = 32767
```

### 2.3 Feral GameMode (`gamemode`)
Ships with both 64-bit and 32-bit GameMode libraries (`gamemode`, `lib32-gamemode`). When a game launches via `gamemoderun %command%` in Steam:
- CPU governor switches to `performance`.
- GPU clock limits are forced to maximum power state.
- Screen savers and power suspension are inhibited.
- Process scheduler niceness is boosted.

---

## 3. Sysctl Kernel Tuning (`/etc/sysctl.d/99-kaze-performance.conf`)

```ini
# Reduce aggressive disk swapping
vm.swappiness = 10

# Maintain cached dentries and inodes longer
vm.vfs_cache_pressure = 50

# Prevent background writeback bursts from stalling interactive tasks
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 134217728

# Maximum file handles
fs.file-max = 2097152

# Low-latency CFS bandwidth slice
kernel.sched_cfs_bandwidth_slice_us = 3000

# Network stack latency reduction
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
```

---

## 4. The Calamares Netinstall Desktop Selector

In Kaze Hayate, Calamares includes a netinstall module (`netinstall.yaml`) allowing users to choose their desktop environment during installation with guaranteed official repository packages:

```yaml
- name: "Desktop Interface"
  description: "Select your preferred user interface"
  critical: true
  expanded: true
  items:
    - name: "KDE Plasma 6 (Tuned Gaming Profile)"
      description: "Low-latency Wayland session with FreeSync/G-Sync and HDR support (Default)"
      selected: true
      packages:
        - plasma-meta
        - plasma-wayland-session
        - sddm
    - name: "Hyprland (Performance Rice)"
      description: "Lightweight, minimal RAM Wayland tiling compositor"
      selected: false
      packages:
        - hyprland
        - waybar
        - kitty
    - name: "GNOME 46 (Wayland)"
      description: "Streamlined modern desktop"
      selected: false
      packages:
        - gnome
        - gdm
    - name: "Headless / CLI"
      description: "Minimal Arch installation without graphical display manager"
      selected: false
      packages: []
```

---

## 5. Package Manifest (`flavors/hayate/packages.flavor`)

```text
# Kernel Stack (CachyOS with Zen fallback)
linux-cachyos
linux-cachyos-headers
linux-zen
linux-zen-headers

# Performance Daemons & Utilities
ananicy-cpp
cachyos-ananicy-rules
zram-generator
gamemode
lib32-gamemode
cpupower
schedtool

# Gaming & Compatibility Stack
wine-staging
winetricks
vulkan-tools
mesa-demos
mangohud
lib32-mangohud
goverlay

# GPU Drivers & Vulkan Stack
vulkan-radeon
lib32-vulkan-radeon
vulkan-intel
lib32-vulkan-intel
nvidia-prime

# Distro Identity & Tools
kaze-branding
kaze-cli
```
