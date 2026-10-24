#!/usr/bin/env bash
# ==============================================================================
# KAZE OS: MASTER BUILD ENGINE CONTROLLER (build.sh)
# Builds specialized Arch Linux ISO images for Hayate, Kasumi, and Nagomi.
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"
CORE_DIR="${SCRIPT_DIR}/core"
FLAVORS_DIR="${SCRIPT_DIR}/flavors"
REPO_DIR="${SCRIPT_DIR}/repo/x86_64"

FLAVOR=""
VERSION="1.0.0"
CLEAN=false
ASSEMBLE_ONLY=false
VERBOSE=false

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}${BOLD}[KAZE-INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[KAZE-SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[KAZE-WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[KAZE-ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$1${NC}"
}

print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
  ██╗  ██╗ █████╗ ███████╗███████╗     ██████╗ ███████╗
  ██║ ██╔╝██╔══██╗╚══███╔╝██╔════╝    ██╔═══██╗██╔════╝
  █████╔╝ ███████║  ███╔╝ █████╗      ██║   ██║███████╗
  ██╔═██╗ ██╔══██║ ███╔╝  ██╔══╝      ██║   ██║╚════██║
  ██║  ██╗██║  ██║███████╗███████╗    ╚██████╔╝███████║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚══════╝
EOF
    echo -e "${NC}${BOLD}Kaze OS Unified Build Engine (風) - v${VERSION}${NC}\n"
}

usage() {
    cat << EOF
Usage: $(basename "$0") --flavor <hayate|kasumi|nagomi> [options]

Core Options:
  -f, --flavor <name>       Target distribution flavor to build:
                              hayate : Performance & Gaming (BORE scheduler, CachyOS kernel)
                              kasumi : Aesthetic Rice (Hyprland Lua, QuickShell QML, Matugen)
                              nagomi : Daily Driver (KDE Plasma 6, Discover/Flathub, Pamac)
  -c, --clean               Clean work and build caches before starting
  -a, --assemble-only       Synthesize and validate the profile without calling mkarchiso
  -v, --version <ver>       Specify release version (default: 1.0.0)
  -w, --work-dir <path>     Custom working directory (default: ./work)
  -o, --out-dir <path>      Custom output directory (default: ./out)
  --verbose                 Enable verbose command tracing
  -h, --help                Show this help message and exit

Examples:
  sudo ./build.sh --flavor kasumi
  sudo ./build.sh --flavor hayate --clean
  ./build.sh --flavor nagomi --assemble-only
EOF
    exit 1
}

# ------------------------------------------------------------------------------
# Argument Parsing
# ------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--flavor)
            FLAVOR="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -a|--assemble-only)
            ASSEMBLE_ONLY=true
            shift
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -w|--work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        -o|--out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown argument: $1"
            usage
            ;;
    esac
done

if [[ "$VERBOSE" == "true" ]]; then
    set -x
fi

# ------------------------------------------------------------------------------
# Pre-flight Checks
# ------------------------------------------------------------------------------
preflight_checks() {
    log_step "Phase 0: Executing pre-flight environment checks"

    # Validate flavor selection
    if [[ -z "$FLAVOR" ]]; then
        log_error "Flavor is required! Specify --flavor [hayate|kasumi|nagomi]"
        usage
    fi

    case "$FLAVOR" in
        hayate|kasumi|nagomi)
            log_info "Selected Flavor: ${BOLD}Kaze ${FLAVOR^}${NC}"
            ;;
        *)
            log_error "Invalid flavor: '$FLAVOR'. Must be 'hayate', 'kasumi', or 'nagomi'."
            exit 1
            ;;
    esac

    # Check required host utilities
    local REQUIRED_BINS=("cp" "awk" "sed" "grep")
    for bin in "${REQUIRED_BINS[@]}"; do
        if ! command -v "$bin" &>/dev/null; then
            log_error "Missing required build tool: '$bin'."
            exit 1
        fi
    done

    if command -v rsync &>/dev/null; then
        log_info "Using 'rsync' for directory synchronization."
    else
        log_info "'rsync' not found; using standard 'cp -a' for directory synchronization."
    fi

    # If full ISO compilation is requested, check root and mkarchiso
    if [[ "$ASSEMBLE_ONLY" == "false" ]]; then
        if [[ $EUID -ne 0 ]]; then
            log_error "Full ISO compilation requires root privileges. Please re-run with 'sudo'."
            log_info "Tip: Use '--assemble-only' to assemble and validate profiles without root."
            exit 1
        fi

        if ! command -v mkarchiso &>/dev/null; then
            log_error "Command 'mkarchiso' not found. Please install the 'archiso' package: 'sudo pacman -S archiso'"
            exit 1
        fi
    else
        log_info "Running in ${BOLD}--assemble-only${NC} mode (Root privileges not required)."
    fi

    # Verify input directories exist
    if [[ ! -d "$CORE_DIR/archiso" ]]; then
        log_error "Core archiso directory missing: $CORE_DIR/archiso"
        exit 1
    fi

    if [[ ! -f "$CORE_DIR/packages.common" ]]; then
        log_error "Common packages list missing: $CORE_DIR/packages.common"
        exit 1
    fi

    local FLAVOR_DIR="${FLAVORS_DIR}/${FLAVOR}"
    if [[ ! -d "$FLAVOR_DIR" ]]; then
        log_error "Flavor directory missing: $FLAVOR_DIR"
        exit 1
    fi

    if [[ ! -f "$FLAVOR_DIR/packages.flavor" ]]; then
        log_error "Flavor packages list missing: $FLAVOR_DIR/packages.flavor"
        exit 1
    fi

    log_success "Pre-flight checks passed successfully."
}

# ------------------------------------------------------------------------------
# Directory Synchronization Helper
# ------------------------------------------------------------------------------
copy_tree() {
    local src="$1"
    local dest="$2"
    mkdir -p "$dest"
    if command -v rsync &>/dev/null; then
        rsync -aK "$src/" "$dest/"
    else
        cp -a "$src/." "$dest/"
    fi
}

# ------------------------------------------------------------------------------
# Workspace Cleaning
# ------------------------------------------------------------------------------
clean_workspace() {
    log_step "Cleaning workspace directories"
    if [[ -d "$WORK_DIR" ]]; then
        log_info "Removing working directory: $WORK_DIR"
        rm -rf "$WORK_DIR"
    fi
    mkdir -p "$WORK_DIR" "$OUT_DIR"
    log_success "Workspace clean complete."
}

# ------------------------------------------------------------------------------
# Profile Synthesis
# ------------------------------------------------------------------------------
assemble_profile() {
    local PROFILE_DIR="${WORK_DIR}/profile"
    local FLAVOR_DIR="${FLAVORS_DIR}/${FLAVOR}"

    log_step "Phase 1: Synthesizing transient archiso profile for Kaze ${FLAVOR^}"

    # Step 1: Initialize clean profile from core
    log_info "Mirroring core archiso skeleton to: $PROFILE_DIR"
    rm -rf "$PROFILE_DIR"
    mkdir -p "$PROFILE_DIR"
    copy_tree "${CORE_DIR}/archiso" "$PROFILE_DIR"

    # Step 2: Merge package manifests with deduplication and comment removal
    log_info "Merging common and flavor package manifests..."
    local PKG_OUT="${PROFILE_DIR}/packages.x86_64"
    {
        cat "${CORE_DIR}/packages.common"
        echo ""
        cat "${FLAVOR_DIR}/packages.flavor"
    } | awk '
        /^[[:space:]]*#/ { next }       # Ignore comments
        /^[[:space:]]*$/ { next }       # Ignore empty lines
        { gsub(/^[[:space:]]+|[[:space:]]+$/, ""); } # Strip whitespace
        !seen[$0]++                     # Deduplicate keeping original order
    ' > "$PKG_OUT"

    local PKG_COUNT
    PKG_COUNT=$(wc -l < "$PKG_OUT")
    log_success "Generated packages.x86_64 with ${PKG_COUNT} unique packages."

    # Step 3: Layer flavor-specific airootfs overlay
    if [[ -d "${FLAVOR_DIR}/airootfs" ]]; then
        log_info "Overlaying flavor airootfs from ${FLAVOR_DIR}/airootfs..."
        copy_tree "${FLAVOR_DIR}/airootfs" "${PROFILE_DIR}/airootfs"
    fi

    # Step 4: Layer Calamares installer configurations and branding via overlay
    # Note: Staged in /root/calamares-overlay so pacstrap installs cachyos-calamares
    # cleanly without filesystem collisions. Applied via customize_airootfs.sh & hook.
    local CALAMARES_DEST="${PROFILE_DIR}/airootfs/root/calamares-overlay"
    mkdir -p "$CALAMARES_DEST"

    if [[ -d "${CORE_DIR}/calamares" ]]; then
        log_info "Staging shared Calamares configuration to overlay..."
        copy_tree "${CORE_DIR}/calamares" "$CALAMARES_DEST"
    fi

    if [[ -d "${FLAVOR_DIR}/calamares" ]]; then
        log_info "Overlaying flavor Calamares branding and modules..."
        copy_tree "${FLAVOR_DIR}/calamares" "$CALAMARES_DEST"
    fi

    if [[ -f "${CALAMARES_DEST}/settings.conf" ]]; then
        log_info "Setting Calamares branding to: kaze-${FLAVOR}"
        sed -i "s|^branding:.*|branding: kaze-${FLAVOR}|g" "${CALAMARES_DEST}/settings.conf"
    fi

    # Create /root/customize_airootfs.sh to apply overlay post-pacstrap
    cat << 'EOF' > "${PROFILE_DIR}/airootfs/root/customize_airootfs.sh"
#!/usr/bin/env bash
set -e

# Apply custom Calamares overlay if present
if [[ -d /root/calamares-overlay ]]; then
    echo "==> Applying Kaze custom Calamares configuration overlay..."
    mkdir -p /etc/calamares
    cp -a /root/calamares-overlay/. /etc/calamares/
    rm -rf /root/calamares-overlay
fi
EOF
    chmod +x "${PROFILE_DIR}/airootfs/root/customize_airootfs.sh"

    # Create pacman PostTransaction hook as an additional overlay trigger
    mkdir -p "${PROFILE_DIR}/airootfs/etc/pacman.d/hooks"
    cat << 'EOF' > "${PROFILE_DIR}/airootfs/etc/pacman.d/hooks/90-kaze-calamares-overlay.hook"
# remove from airootfs!
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = cachyos-calamares

[Action]
Description = Applying Kaze custom Calamares configuration overlay...
When = PostTransaction
Depends = coreutils
Exec = /bin/sh -c "if [ -d /root/calamares-overlay ]; then cp -a /root/calamares-overlay/. /etc/calamares/ && rm -rf /root/calamares-overlay; fi"
EOF

    # Step 5: Configure local package repository if present
    if [[ -d "$REPO_DIR" && -f "$REPO_DIR/kaze.db.tar.gz" ]]; then
        log_info "Detected local Kaze binary repository at $REPO_DIR"
        sed -i "s|@REPO_DIR@|${SCRIPT_DIR}/repo|g" "${PROFILE_DIR}/pacman.conf"
        sed -i "s|@REPO_DIR@|${SCRIPT_DIR}/repo|g" "${PROFILE_DIR}/airootfs/etc/pacman.conf"
    else
        log_info "Local repository kaze.db.tar.gz not found (using remote repos)."
        sed -i "s|file://@REPO_DIR@/\$arch|https://kaze-os.github.io/repo/\$arch|g" "${PROFILE_DIR}/pacman.conf"
        sed -i "s|file://@REPO_DIR@/\$arch|https://kaze-os.github.io/repo/\$arch|g" "${PROFILE_DIR}/airootfs/etc/pacman.conf"
    fi

    # Step 6: Customize profiledef.sh metadata for flavor
    local PROFILEDEF="${PROFILE_DIR}/profiledef.sh"
    local FLAVOR_UPPER="${FLAVOR^^}"
    local ISO_BASE_NAME="kaze-${FLAVOR}-${VERSION}-x86_64"

    log_info "Customizing profiledef.sh for Kaze ${FLAVOR^} (ISO: ${ISO_BASE_NAME}.iso)..."
    sed -i "s|^iso_name=.*|iso_name=\"kaze-${FLAVOR}\"|g" "$PROFILEDEF"
    sed -i "s|^iso_label=.*|iso_label=\"KAZE_${FLAVOR_UPPER}_$(date +%Y%m)\"|g" "$PROFILEDEF"
    sed -i "s|^iso_application=.*|iso_application=\"Kaze OS (${FLAVOR^}) Live/Installation Media\"|g" "$PROFILEDEF"
    sed -i "s|^iso_version=.*|iso_version=\"${VERSION}\"|g" "$PROFILEDEF"

    # Set Live Hostname based on flavor
    mkdir -p "${PROFILE_DIR}/airootfs/etc"
    echo "kaze-${FLAVOR}" > "${PROFILE_DIR}/airootfs/etc/hostname"

    log_success "Profile assembly for Kaze ${FLAVOR^} completed in: $PROFILE_DIR"
}

# ------------------------------------------------------------------------------
# Build Execution (mkarchiso)
# ------------------------------------------------------------------------------
execute_build() {
    local PROFILE_DIR="${WORK_DIR}/profile"
    local TMP_DIR="${WORK_DIR}/tmp"
    local ISO_FILE="${OUT_DIR}/kaze-${FLAVOR}-${VERSION}-x86_64.iso"

    if [[ "$ASSEMBLE_ONLY" == "true" ]]; then
        log_step "Phase 2: Assemble-only mode requested. Skipping mkarchiso."
        log_success "Profile verification complete. Profile is ready at: $PROFILE_DIR"
        return 0
    fi

    log_step "Phase 2: Executing mkarchiso image compiler"
    log_info "Work cache: $TMP_DIR"
    log_info "Output dir: $OUT_DIR"

    mkdir -p "$TMP_DIR" "$OUT_DIR"

    # Invoke mkarchiso
    mkarchiso -v -w "$TMP_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

    # Generate Checksums
    log_step "Phase 3: Checksum Generation"
    if [[ -f "$ISO_FILE" ]]; then
        log_info "Computing SHA256 checksum for: $ISO_FILE"
        sha256sum "$ISO_FILE" > "${ISO_FILE}.sha256"
        log_success "ISO Image built successfully: $ISO_FILE"
        log_success "SHA256: $(cat "${ISO_FILE}.sha256")"
        # Hand ownership back to the non-root user if running under sudo
        if [[ -n "${SUDO_USER:-}" ]]; then
            chown -R "$SUDO_USER:$(id -gn "$SUDO_USER")" "$OUT_DIR" "$WORK_DIR" 2>/dev/null || true
        fi
    else
        log_error "Expected ISO file was not found in $OUT_DIR after mkarchiso!"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Main Flow
# ------------------------------------------------------------------------------
main() {
    print_banner
    preflight_checks

    if [[ "$CLEAN" == "true" ]]; then
        clean_workspace
    else
        mkdir -p "$WORK_DIR" "$OUT_DIR"
    fi

    assemble_profile
    execute_build

    log_step "Build Engine Process Completed Successfully"
}

main "$@"
