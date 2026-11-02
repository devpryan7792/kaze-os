// Kaze OS Interactive Portal Logic
const flavorData = {
  kasumi: {
    name: "霞 KASUMI",
    tagline: "Mist · Aesthetic Wayland Rice & Dynamic Design",
    desktop: "Hyprland (Modular Lua) + QuickShell (QML)",
    kernel: "Standard Linux Kernel (Clean upstream)",
    latency: "144 Hz wallpaper transitions via awww",
    theming: "Matugen dynamic Material You tokens from wallpaper",
    packages: "kaze-cli, ghostty, fuzzel, waybar, matugen",
    terminal: [
      '<span class="term-comment"># Kasumi Phase 1 Profile Assembly</span>',
      '<span class="term-cyan">$</span> ./build.sh -f kasumi',
      '<span class="term-green">[1/5]</span> Merging core/packages.common + flavors/kasumi/packages.flavor',
      '<span class="term-green">[2/5]</span> Layering flavors/kasumi/airootfs overlay',
      '<span class="term-green">[3/5]</span> Generating modular Lua bindings in /etc/skel/.config/hypr/',
      '<span class="term-green">[4/5]</span> Linking QuickShell QML desktop bar & dynamic colors.json',
      '<span class="term-cyan">[5/5]</span> Built profile: out/kaze-kasumi-archiso.profile'
    ]
  },
  hayate: {
    name: "疾風 HAYATE",
    tagline: "Gale · Low-Latency Gaming & Heavy Compute",
    desktop: "Tuned KDE Plasma 6 (Wayland) + Netinstall DE selector",
    kernel: "linux-cachyos (BORE scheduler, MGLRU, -O3, x86-64-v3)",
    latency: "ananicy-cpp auto-renice + gamemode + zram (zstd)",
    theming: "Blur disabled, native Variable Refresh Rate (VRR)",
    packages: "steam, vulkan-tools, mangohud, cachyos-gaming-meta",
    terminal: [
      '<span class="term-comment"># Hayate Phase 1 Profile Assembly</span>',
      '<span class="term-purple">$</span> ./build.sh -f hayate',
      '<span class="term-green">[1/5]</span> Ingesting CachyOS v3 performance repos & keyring',
      '<span class="term-green">[2/5]</span> Injecting BORE CPU scheduler sysctl optimizations',
      '<span class="term-green">[3/5]</span> Configuring gamemode & ananicy rule trees for 200+ games',
      '<span class="term-green">[4/5]</span> Disabling desktop compositor blurs for minimum frame-time jitter',
      '<span class="term-purple">[5/5]</span> Built profile: out/kaze-hayate-archiso.profile'
    ]
  },
  nagomi: {
    name: "和 NAGOMI",
    tagline: "Harmony · Resilient Daily Driver & Engineering Workstation",
    desktop: "KDE Plasma 6 (Wayland) · GNOME alternative option",
    kernel: "Standard Linux LTS / Stable",
    latency: "power-profiles-daemon for extended laptop battery",
    theming: "Refined, cohesive dark defaults with high contrast",
    packages: "pamac-aur, flathub-backend, kaze-welcome, timeshift",
    terminal: [
      '<span class="term-comment"># Nagomi Phase 1 Profile Assembly</span>',
      '<span class="term-green">$</span> ./build.sh -f nagomi',
      '<span class="term-green">[1/5]</span> Layering Calamares turnkey installer branding',
      '<span class="term-green">[2/5]</span> Initializing automated Flathub repo & Pamac GUI hooks',
      '<span class="term-green">[3/5]</span> Configuring laptop sleep/wake & power-profiles daemon',
      '<span class="term-green">[4/5]</span> Provisioning Btrfs automated snap-pac hooks',
      '<span class="term-green">[5/5]</span> Built profile: out/kaze-nagomi-archiso.profile'
    ]
  }
};

document.addEventListener('DOMContentLoaded', () => {
  // Flavor Tabs Switcher
  const tabs = document.querySelectorAll('.flavor-tab');
  const flavorName = document.getElementById('flavor-name');
  const flavorTagline = document.getElementById('flavor-tagline');
  const specDesktop = document.getElementById('spec-desktop');
  const specKernel = document.getElementById('spec-kernel');
  const specLatency = document.getElementById('spec-latency');
  const specTheming = document.getElementById('spec-theming');
  const termBody = document.getElementById('flavor-term-body');

  function setFlavor(flavorKey) {
    const data = flavorData[flavorKey];
    if (!data) return;

    tabs.forEach(t => {
      if (t.dataset.flavor === flavorKey) {
        t.classList.add('active');
      } else {
        t.classList.remove('active');
      }
    });

    flavorName.textContent = data.name;
    flavorTagline.textContent = data.tagline;
    specDesktop.textContent = data.desktop;
    specKernel.textContent = data.kernel;
    specLatency.textContent = data.latency;
    specTheming.textContent = data.theming;

    termBody.innerHTML = data.terminal.map(line => `<div>${line}</div>`).join('');
  }

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      setFlavor(tab.dataset.flavor);
    });
  });

  // Rollback Simulator
  const btnRollback = document.getElementById('btn-sim-rollback');
  const subvolRoot = document.getElementById('subvol-root');
  const subvolHome = document.getElementById('subvol-home');
  const rollbackLog = document.getElementById('rollback-status');

  let isBroken = false;

  btnRollback.addEventListener('click', () => {
    if (!isBroken) {
      // Simulate broken state
      subvolRoot.style.borderColor = '#fb7185';
      subvolRoot.style.background = 'rgba(251, 113, 133, 0.15)';
      subvolHome.style.borderColor = '#34d399';
      rollbackLog.innerHTML = '<span class="term-amber">⚠️ Bad kernel upgrade broke system root (@)! Click to trigger GRUB Btrfs 30s Rollback...</span>';
      btnRollback.textContent = 'Execute grub-btrfs Rollback';
      btnRollback.style.background = '#fb7185';
      btnRollback.style.color = '#000';
      isBroken = true;
    } else {
      // Revert cleanly
      subvolRoot.style.borderColor = '#34d399';
      subvolRoot.style.background = 'rgba(52, 211, 153, 0.15)';
      rollbackLog.innerHTML = '<span class="term-green">✓ Rolled back system root (@) to pre-upgrade snapshot #42! /home and /var/log remained 100% intact.</span>';
      btnRollback.textContent = 'Simulate Broken Update';
      btnRollback.style.background = '';
      btnRollback.style.color = '';
      isBroken = false;
      setTimeout(() => {
        subvolRoot.style.borderColor = '';
        subvolRoot.style.background = '';
      }, 4000);
    }
  });
});
