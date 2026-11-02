<!-- https://github.com/devpryan7792/kaze-os -->

<div align="center">

# 🌬️ Kaze OS

**風 — *Motion, Flow, Power***

An ecosystem of three hyper-focused Arch Linux distributions,
engineered from a single modular build engine.

[![CI · ISO Build](https://github.com/devpryan7792/kaze-os/actions/workflows/build-iso.yml/badge.svg)](https://github.com/devpryan7792/kaze-os/actions/workflows/build-iso.yml)
[![CI · Packages](https://github.com/devpryan7792/kaze-os/actions/workflows/build-packages.yml/badge.svg)](https://github.com/devpryan7792/kaze-os/actions/workflows/build-packages.yml)
[![Base](https://img.shields.io/badge/base-Arch_Linux-blue?logo=archlinux&logoColor=white)](https://archlinux.org)
[![Interactive Portal](https://img.shields.io/badge/interactive-portal-38bdf8?style=flat-square&logo=safari&logoColor=white)](https://devpryan7792.github.io/kaze-os/)
[![Platform](https://img.shields.io/badge/platform-x86__64-informational)](./build.sh)
[![License: MIT](https://img.shields.io/badge/license-MIT-orange)](./LICENSE)

</div>

> [!NOTE]
> **Phase 1 Research & Architecture Prototype**: The core build engine, Btrfs subvolume layout, and flavor overlays are implemented in code. Production ISO compilation and automated package mirrors are undergoing active refining. Explore the live interactive architecture at **[devpryan7792.github.io/kaze-os](https://devpryan7792.github.io/kaze-os/)**.

---

## 💡 Why Kaze OS?

No single operating system can maximize competitive gaming, minimalist tiling ricing, *and*
beginner-friendly productivity without bloat or compromise. Kaze OS doesn't try — it splits
into **three independent, hyper-tuned flavors** sharing one resilient, "unbreakable" foundation:

```
                        ┌───────────────────────────────┐
                        │       KAZE OS CORE ENGINE     │
                        │   archiso · btrfs · pkgs · CI │
                        └───────────────┬───────────────┘
                                        │
          ┌─────────────────────────────┼─────────────────────────────┐
          ▼                             ▼                             ▼
  ┌───────────────┐            ┌───────────────┐            ┌───────────────┐
  │  疾風 HAYATE  │            │   霞 KASUMI   │            │   和 NAGOMI   │
  │     Gale      │            │     Mist      │            │   Harmony     │
  │  Performance  │            │  Aesthetic    │            │  Daily Driver │
  │               │            │     Rice      │            │               │
  └───────────────┘            └───────────────┘            └───────────────┘
```

### ⛩️ The Three Flavors

| | ⚡ **疾風 Hayate** | 🎨 **霞 Kasumi** | 🛡️ **和 Nagomi** |
|---|---|---|---|
| **Built for** | Gamers, 3D renderers, low-latency workloads | Ricers, designers, Wayland purists | Students, engineers, first-time Arch users |
| **Desktop** | Tuned KDE Plasma 6 (Wayland) · Netinstall DE selector | Hyprland (modular Lua) + QuickShell (QML) | KDE Plasma 6 · GNOME installer alternative |
| **Kernel** | `linux-cachyos` — BORE scheduler, MGLRU, `-O3`, x86-64-v3 | Standard Linux | Standard Linux |
| **Latency** | `ananicy-cpp` + `gamemode` + zram (zstd) | 144 Hz transitions via `awww` | `power-profiles-daemon` laptop tuning |
| **Theming** | Blur off, native VRR | Matugen Material-You dynamic palette | Clean, welcoming defaults |
| **Software** | Steam-ready out of the box | `kaze-cli`, `ghostty`, curated wallpapers | Discover + Flathub, Pamac AUR manager |

---

## ✨ Highlights

### 🧩 One monorepo, three operating systems
All flavors are *overlays* on a shared, validated core (`core/archiso` + `core/calamares`).
Fix the installer once — all three ISOs benefit. Flavors never drift apart.

### 🛟 Unbreakable Arch, by design
Every flavor ships a 5-subvolume **Btrfs** topology with automated **pre/post `pacman`
snapshots** (snap-pac) and **boot-menu rollbacks** (grub-btrfs). A broken update is a
30-second rollback — and `/home` is never touched:

| Subvolume | Mounted at | Role |
|---|---|---|
| `@` | `/` | System root — **snapshotted & rolled back** |
| `@home` | `/home` | User data — **never touched by rollback** |
| `@snapshots` | `/.snapshots` | Snapper snapshot metadata |
| `@var_log` | `/var/log` | Journal preserved for post-rollback debugging |
| `@var_cache` | `/var/cache` | Pacman cache preserved |

### 🖌️ Kasumi's dual-tier rice strategy
**Tier 1** (guaranteed, from official Arch repos): Hyprland + waybar + fuzzel + kitty — a
fully functional Wayland desktop with zero fragility.
**Tier 2** (enhanced, from the Kaze repo): QuickShell widgets, Matugen dynamic palette,
`awww` 144 Hz wallpaper transitions, Ghostty. Tier 2 enhances; Tier 1 never breaks.

### 🛠️ `kaze-cli` — the distro's control panel
```sh
kaze-cli wallpaper ~/path/to/img   # set wallpaper → triggers live Matugen reload
kaze-cli scheme vibrant            # tonal-spot | vibrant | expressive | neutral
kaze-cli sync                      # pull config updates (backs up your configs first)
kaze-cli doctor                    # GPU, audio, Hyprland plugin & shell diagnostics
```

### 🏭 Built like a top-tier distro, CI included
- `build-packages.yml` — compiles every PKGBUILD in an Arch container on any change to `pkgs/`, publishes to the Kaze pacman repo via GitHub Releases/Pages.
- `build-iso.yml` — builds flavor ISOs on runners with 30+ GB reclaimed disk space; publishes `.iso` + SHA256 checksums.

---

## 🚀 Quick Start

### Build a flavor
```sh
# Clone and pick your fighter
git clone https://github.com/devpryan7792/kaze-os.git && cd kaze-os

# Requires: archiso, pacman, sudo
sudo pacman -S --needed archiso

# Build (hayate | kasumi | nagomi) to ./out/
sudo ./build.sh -f kasumi
```
Output: `out/kaze-<flavor>-<version>-x86_64.iso` + `.sha256`.

### Test-drive it in QEMU
```sh
./launch.sh -i out/kaze-kasumi-1.0.0-x86_64.iso
```
Or rebuild a new ISO straight into the test harness with `-r`.

### Assemble locally, install the custom packages by hand
```sh
sudo ./build.sh -f nagomi -a          # assemble profile only
./repo/update-repo.sh                 # build the local pacman repo
```

---

## 🏛️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                  TIER 3 · FLAVOR OVERLAYS                        │
│   flavors/hayate/   flavors/kasumi/   flavors/nagomi/            │
└───────────────────────────────────┬──────────────────────────────┘
                                    │ overlay (rsync -aK) at build time
┌───────────────────────────────────▼──────────────────────────────┐
│                  TIER 2 · SHARED CORE ENGINE                     │
│   core/archiso/ · core/calamares/ · core/packages.common         │
└───────────────────────────────────┬──────────────────────────────┘
                                    │ consumes
┌───────────────────────────────────▼──────────────────────────────┐
│                  TIER 1 · PACKAGE DELIVERY                       │
│        Arch official · CachyOS (v3) · Kaze custom repo           │
└──────────────────────────────────────────────────────────────────┘
```

**Build flow:** `core/packages.common` + `flavors/*/packages.flavor` are merged & deduped,
the flavor `airootfs/` is layered on top, Calamares branding is injected, then `mkarchiso` runs.

### 📦 Custom packages (`pkgs/`)

| Package | What it is |
|---|---|
| `kaze-cli` | Unified distro shell utility (wallpaper, palette, sync, doctor) |
| `kaze-welcome` | First-boot GUI setup: mirror ranking, GPU driver detection, app bundles |
| `kaze-branding` | Wallpapers, logos, GTK/Qt defaults, Plymouth boot splash |
| `quickshell-git` | QtQuick/QML desktop shell powering the Kasumi bar, launcher & control center |
| `awww-bin` | Rust wallpaper daemon with 144 Hz animated wipes |
| `matugen-bin` | Material You dynamic color token generator |

### 🗂️ Repository layout

```text
kaze-os/
├── build.sh                     # 🔧 Master build engine
├── launch.sh                    # 🖥️ QEMU test launcher
├── core/                        # Shared archiso profile, Calamares modules, pkg list
│   ├── archiso/ · calamares/ · packages.common · scripts/
├── flavors/                     # Per-flavor overlays
│   ├── hayate/ · kasumi/ · nagomi/
├── pkgs/                        # PKGBUILDs for custom packages
│   └── kaze-cli/ · kaze-welcome/ · kaze-branding/ · quickshell-git/ · awww-bin/ · matugen-bin/
├── repo/                        # Local pacman repo tooling
├── .github/workflows/           # build-iso.yml · build-packages.yml
├── DISTRO_BLUEPRINT.md          # Master specification
├── ARCHITECTURE.md              # Technical architecture document
├── SPEC_{HAYATE,KASUMI,NAGOMI}.md  # Per-flavor specifications
└── ROADMAP.md                   # Implementation milestones
```

---

## 🗺️ Roadmap

- [x] Core archiso base + profile assembly engine
- [x] Kasumi Tier 1 Wayland environment + modular Lua Hyprland config
- [x] Btrfs/Snapper subvolume topology & Calamares modules
- [x] PKGBUILDs for `kaze-cli`, `kaze-branding`, `awww`, `matugen`, `quickshell`
- [x] GH Actions: package repo publishing + ISO builds
- [ ] Verified QEMU boot on all three flavors
- [ ] Live `kaze.db` repository hosting + first tagged releases
- [ ] Hayate x86-64-v3 mirror auto-detection
- [ ] Nagomi GNOME installer toggle polish
- [ ] Kaze OS `pacman` repo at `https://kaze-os.github.io/repo/x86_64/`

Full detail lives in [`ROADMAP.md`](./ROADMAP.md).

---

## 🤝 Contributing

Contributions, rices, and bug reports are welcome — pick a flavor, fork, and send a PR:

1. Fork the repo and create your branch: `git checkout -b feat/my-feature`
2. Make your change — keep flavor-specific edits inside `flavors/<flavor>/`, shared fixes in `core/`
3. Assemble the profile (`sudo ./build.sh -f <flavor> -a`) to sanity-check the merge
4. Commit with a conventional message and open a Pull Request

For bug reports, include the flavor, qemu/config logs from `kaze-cli doctor`, and steps to reproduce.

---

## 📜 License

Released under the [MIT License](./LICENSE).

## 🙏 Acknowledgements

Kaze OS stands on the shoulders of giants:

- **Arch Linux** & the **archiso** team
- **CachyOS** — kernel, v3 repos & performance tuning philosophy
- **Hyprland**, **QuickShell**, **Matugen**, **awww** — the Kasumi rice stack
- **Calamares**, **Snapper**, **grub-btrfs** — the unbreakable foundation

<div align="center">

**Kaze OS** — *Motion. Flow. Power.* `風`

</div>
