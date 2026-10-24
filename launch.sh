#!/usr/bin/env bash
# ==============================================================================
# KAZE OS: QEMU VIRTUAL TEST LAUNCHER (launch.sh)
# Launches Kaze Kasumi, Hayate, or Nagomi in hardware-accelerated QEMU.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/test-lab"
OUT_DIR="${SCRIPT_DIR}/out"

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p "$TEST_DIR"

log_info() {
    echo -e "${BLUE}${BOLD}[LAUNCH-INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[LAUNCH-SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[LAUNCH-WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[LAUNCH-ERROR]${NC} $1" >&2
}

print_header() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
  ██╗  ██╗ █████╗ ███████╗███████╗     ████████╗███████╗███████╗████████╗
  ██║ ██╔╝██╔══██╗╚══███╔╝██╔════╝     ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
  █████╔╝ ███████║  ███╔╝ █████╗          ██║   █████╗  ███████╗   ██║   
  ██╔═██╗ ██╔══██║ ███╔╝  ██╔══╝          ██║   ██╔══╝  ╚════██║   ██║   
  ██║  ██╗██║  ██║███████╗███████╗        ██║   ███████╗███████║   ██║   
  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝        ╚═╝   ╚══════╝╚══════╝   ╚═╝   
EOF
    echo -e "${NC}${BOLD}Kaze OS Virtual Machine Test Launcher (風)${NC}\n"
}

# ------------------------------------------------------------------------------
# Locate UEFI Firmware
# ------------------------------------------------------------------------------
find_uefi_firmware() {
    local CODE_PATHS=(
        "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
        "/usr/share/edk2/x64/OVMF_CODE.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
        "/usr/share/OVMF/x64/OVMF_CODE.4m.fd"
        "/usr/share/OVMF/OVMF_CODE.fd"
    )

    local VARS_PATHS=(
        "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
        "/usr/share/edk2/x64/OVMF_VARS.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_VARS.4m.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd"
        "/usr/share/OVMF/x64/OVMF_VARS.4m.fd"
        "/usr/share/OVMF/OVMF_VARS.fd"
    )

    OVMF_CODE=""
    OVMF_VARS_TEMPLATE=""

    for path in "${CODE_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            OVMF_CODE="$path"
            break
        fi
    done

    for path in "${VARS_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            OVMF_VARS_TEMPLATE="$path"
            break
        fi
    done

    if [[ -z "$OVMF_CODE" ]]; then
        log_error "UEFI OVMF firmware not found! Install 'edk2-ovmf' package."
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Select Flavor
# ------------------------------------------------------------------------------
show_help() {
    echo -e "Usage: $0 [kasumi | hayate | nagomi | /path/to/any.iso] [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --fresh, --reset   Wipe virtual disks & NVRAM and create a fresh 30GB disk"
    echo "  -i, --iso <path>   Launch a specific custom ISO file directly"
    echo "  -r, --rebuild      Recompile the ISO using 'sudo ./build.sh' before launching"
    echo "  -h, --help         Show this help message and exit"
    echo ""
    echo "If no flavor argument is provided, launch.sh presents an interactive menu."
    echo "Virtual machine disks (*.qcow2) and NVRAM stores are preserved in test-lab/."
    exit 0
}

REBUILD=false
RESET_ONLY=false
CUSTOM_ISO=""

reset_environment() {
    log_info "Resetting test environment in ${TEST_DIR}..."
    rm -f "${TEST_DIR}"/*.qcow2 "${TEST_DIR}"/*.fd
    log_success "Cleaned previous virtual disks and NVRAM."
    log_info "Creating fresh 30GB virtual disk: ${TEST_DIR}/kaze-test-disk.qcow2"
    qemu-img create -f qcow2 "${TEST_DIR}/kaze-test-disk.qcow2" 30G >/dev/null
    log_success "Fresh 30GB testing storage created successfully!"
}

select_flavor() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                ;;
            --fresh|--reset|reset)
                reset_environment
                RESET_ONLY=true
                shift
                ;;
            -i|--iso)
                CUSTOM_ISO="$2"
                shift 2
                ;;
            *.iso)
                CUSTOM_ISO="$1"
                shift
                ;;
            -r|--rebuild)
                REBUILD=true
                shift
                ;;
            kasumi|hayate|nagomi)
                FLAVOR="$1"
                shift
                ;;
            *)
                if [[ -f "$1" && "$1" == *.iso ]]; then
                    CUSTOM_ISO="$1"
                    shift
                else
                    log_error "Unknown option: '$1'. Valid flavors: kasumi, hayate, nagomi or path to .iso"
                    echo "Run '$0 --help' for usage."
                    exit 1
                fi
                ;;
        esac
    done

    if [[ "$RESET_ONLY" == "true" ]]; then
        log_success "Reset complete. Run '$0 [flavor|iso]' to launch fresh VM."
        exit 0
    fi

    if [[ -n "$CUSTOM_ISO" ]]; then
        ISO_PATH="$CUSTOM_ISO"
        FLAVOR="custom"
        return
    fi

    if [[ -n "${FLAVOR:-}" ]]; then
        return
    fi

    echo -e "${BOLD}Select a Kaze OS flavor to test:${NC}"
    echo "  [1] Kaze Kasumi (霞) - Aesthetic Wayland Rice (Hyprland + QuickShell)"
    echo "  [2] Kaze Hayate (疾風) - Low-Latency Performance & Gaming (CachyOS + BORE)"
    echo "  [3] Kaze Nagomi (和) - Daily Driver Workstation (KDE Plasma 6)"
    echo "  [4] Exit"
    echo ""
    read -rp "Enter choice [1-3] (Default: 1): " choice
    choice="${choice:-1}"

    case "$choice" in
        1|kasumi) FLAVOR="kasumi" ;;
        2|hayate) FLAVOR="hayate" ;;
        3|nagomi) FLAVOR="nagomi" ;;
        4|q|exit) exit 0 ;;
        *) log_error "Invalid selection."; exit 1 ;;
    esac
}

# ------------------------------------------------------------------------------
# Locate or Assemble ISO
# ------------------------------------------------------------------------------
prepare_iso() {
    if [[ -n "${ISO_PATH:-}" && -f "$ISO_PATH" ]]; then
        log_success "Using specified ISO: ${BOLD}$ISO_PATH${NC}"
        return 0
    fi

    # Check if a built ISO exists in out/ or test-lab/
    ISO_PATH=$(find "$OUT_DIR" "$TEST_DIR" -name "kaze-${FLAVOR}-*.iso" 2>/dev/null | head -n 1 || true)

    if [[ "$REBUILD" == "true" ]]; then
        log_info "Rebuild flag specified. Initiating build for Kaze ${FLAVOR^}..."
        sudo ./build.sh --flavor "$FLAVOR" --clean
        ISO_PATH=$(find "$OUT_DIR" -name "kaze-${FLAVOR}-*.iso" 2>/dev/null | head -n 1 || true)
        rm -f "${TEST_DIR}/kaze-${FLAVOR}-vars.fd"
    elif [[ -n "$ISO_PATH" && -f "$ISO_PATH" ]]; then
        log_success "Found pre-compiled ISO: ${BOLD}$ISO_PATH${NC}"
        local reuse_choice="1"
        if [[ -t 0 ]]; then
            echo ""
            echo "Would you like to:"
            echo "  [1] Launch existing ISO in QEMU"
            echo "  [2] Rebuild ISO with sudo ./build.sh and launch"
            echo "  [3] Reset virtual disk & NVRAM, then launch"
            echo "  [4] Cancel"
            read -rp "Enter choice [1-4] (Default: 1): " user_choice
            reuse_choice="${user_choice:-1}"
        fi

        case "$reuse_choice" in
            2)
                log_info "Rebuilding ISO for Kaze ${FLAVOR^}..."
                sudo ./build.sh --flavor "$FLAVOR" --clean
                ISO_PATH=$(find "$OUT_DIR" -name "kaze-${FLAVOR}-*.iso" 2>/dev/null | head -n 1 || true)
                rm -f "${TEST_DIR}/kaze-${FLAVOR}-vars.fd"
                ;;
            3)
                log_info "Resetting test virtual storage and NVRAM..."
                rm -f "${TEST_DIR}/kaze-${FLAVOR}-vars.fd" "${TEST_DIR}/kaze-${FLAVOR}-disk.qcow2"
                ;;
            4)
                exit 0
                ;;
            *)
                ;;
        esac
    fi

    if [[ -z "$ISO_PATH" || ! -f "$ISO_PATH" ]]; then
        log_warn "No pre-compiled ISO found for Kaze ${FLAVOR^} in $OUT_DIR."
        if [[ ! -t 0 ]]; then
            log_error "Non-interactive session and no ISO found. Run 'sudo ./build.sh --flavor $FLAVOR' first."
            exit 1
        fi
        echo ""
        echo "Would you like to:"
        echo "  [1] Synthesize profile and build ISO now with sudo ./build.sh"
        echo "  [2] Run profile assembly only (--assemble-only) and exit"
        echo "  [3] Specify custom path to an existing ISO"
        echo "  [4] Cancel"
        read -rp "Enter choice [1-4]: " iso_choice

        case "$iso_choice" in
            1)
                if ! command -v mkarchiso &>/dev/null; then
                    log_warn "'mkarchiso' (package 'archiso') is required to compile live ISOs."
                    read -rp "Install 'archiso' and 'rsync' using pacman now? [Y/n]: " inst_choice
                    if [[ "${inst_choice,,}" != "n" ]]; then
                        sudo pacman -S --needed archiso rsync
                    else
                        log_error "Cannot build ISO without 'mkarchiso'. Run 'sudo pacman -S archiso' manually."
                        exit 1
                    fi
                fi
                log_info "Initiating build for Kaze ${FLAVOR^}..."
                sudo ./build.sh --flavor "$FLAVOR" --clean
                ISO_PATH=$(find "$OUT_DIR" -name "kaze-${FLAVOR}-*.iso" 2>/dev/null | head -n 1 || true)
                rm -f "${TEST_DIR}/kaze-${FLAVOR}-vars.fd"
                ;;
            2)
                log_info "Assembling profile in work/profile..."
                ./build.sh --flavor "$FLAVOR" --assemble-only
                ./core/scripts/verify-profile.sh work/profile
                log_success "Profile ready in work/profile."
                exit 0
                ;;
            3)
                read -rp "Enter absolute path to ISO: " custom_iso
                if [[ -f "$custom_iso" ]]; then
                    ISO_PATH="$custom_iso"
                else
                    log_error "File does not exist: $custom_iso"
                    exit 1
                fi
                ;;
            *)
                exit 0
                ;;
        esac
    fi

    log_success "Using ISO: ${BOLD}$ISO_PATH${NC}"
}

# ------------------------------------------------------------------------------
# Prepare Virtual Disk & NVRAM
# ------------------------------------------------------------------------------
prepare_storage() {
    DISK_IMG="${TEST_DIR}/kaze-${FLAVOR}-disk.qcow2"
    NVRAM_VARS="${TEST_DIR}/kaze-${FLAVOR}-vars.fd"

    if [[ "$FLAVOR" == "custom" ]]; then
        DISK_IMG="${TEST_DIR}/kaze-test-disk.qcow2"
        NVRAM_VARS="${TEST_DIR}/kaze-test-vars.fd"
    fi

    # Virtual Hard Disk (30GB sparse QCOW2 image)
    if [[ ! -f "$DISK_IMG" ]]; then
        log_info "Creating 30GB virtual hard disk (sparse): $DISK_IMG"
        qemu-img create -f qcow2 "$DISK_IMG" 30G > /dev/null
    fi

    # UEFI NVRAM variables file
    if [[ ! -f "$NVRAM_VARS" && -n "$OVMF_VARS_TEMPLATE" ]]; then
        log_info "Creating isolated UEFI NVRAM store: $NVRAM_VARS"
        cp "$OVMF_VARS_TEMPLATE" "$NVRAM_VARS"
    fi
}

# ------------------------------------------------------------------------------
# Launch QEMU
# ------------------------------------------------------------------------------
launch_qemu() {
    local RAM="8G"
    local CPUS="4"

    log_info "Launching QEMU Virtual Machine..."
    log_info "  - Flavor: Kaze ${FLAVOR^}"
    log_info "  - CPU Cores: $CPUS | RAM: $RAM"
    log_info "  - Disk: $DISK_IMG"
    log_info "  - ISO: $ISO_PATH"

    local ACCEL_FLAGS=()
    if [[ -w /dev/kvm ]]; then
        ACCEL_FLAGS=("-enable-kvm" "-cpu" "host")
        log_success "KVM Hardware Virtualization: Enabled"
    else
        ACCEL_FLAGS=("-cpu" "max")
        log_warn "KVM not accessible (/dev/kvm). Running in software emulation."
    fi

    local UEFI_FLAGS=()
    if [[ -f "$NVRAM_VARS" ]]; then
        UEFI_FLAGS=(
            "-drive" "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
            "-drive" "if=pflash,format=raw,file=$NVRAM_VARS"
        )
    else
        UEFI_FLAGS=(
            "-drive" "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
        )
    fi

    echo -e "\n${YELLOW}${BOLD}==================================================================${NC}"
    echo -e "${YELLOW}${BOLD}  KEYBOARD & SHORTCUT GRAB ACTIVE IN VM                           ${NC}"
    echo -e "${YELLOW}${BOLD}  All keys (Super+Q, Super+Return, etc.) go directly to the VM!   ${NC}"
    echo -e "${YELLOW}${BOLD}  To release keyboard / mouse back to host, press: ${CYAN}Ctrl + Alt + G${YELLOW}    ${NC}"
    echo -e "${YELLOW}${BOLD}==================================================================${NC}\n"

    qemu-system-x86_64 \
        "${ACCEL_FLAGS[@]}" \
        -m "$RAM" \
        -smp "$CPUS" \
        -vga virtio \
        -display gtk,grab-on-hover=on,show-cursor=on \
        "${UEFI_FLAGS[@]}" \
        -drive "file=$DISK_IMG,if=virtio,format=qcow2" \
        -cdrom "$ISO_PATH" \
        -boot menu=on,order=d \
        -net nic,model=virtio \
        -net user \
        -audiodev pa,id=snd0 \
        -device intel-hda \
        -device hda-duplex,audiodev=snd0 \
        -device nec-usb-xhci,id=xhci \
        -device usb-tablet,bus=xhci.0
}

# ------------------------------------------------------------------------------
# Main Flow
# ------------------------------------------------------------------------------
main() {
    print_header
    find_uefi_firmware

    select_flavor "$@"
    prepare_iso
    prepare_storage
    launch_qemu
}

main "$@"
