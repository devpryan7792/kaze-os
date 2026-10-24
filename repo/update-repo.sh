#!/usr/bin/env bash
# ==============================================================================
# KAZE OS: LOCAL PACKAGE REPOSITORY BUILDER (repo/update-repo.sh)
# Builds packages from pkgs/ and updates repo/x86_64/kaze.db.tar.gz
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PKGS_DIR="${ROOT_DIR}/pkgs"
REPO_DIR="${SCRIPT_DIR}/x86_64"
DB_NAME="kaze"

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}${BOLD}[REPO-INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[REPO-SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[REPO-WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[REPO-ERROR]${NC} $1" >&2
}

mkdir -p "$REPO_DIR"

build_pkg() {
    local pkg_dir="$1"
    local pkg_name="$(basename "$pkg_dir")"

    if [[ ! -f "$pkg_dir/PKGBUILD" ]]; then
        log_warn "No PKGBUILD found in $pkg_dir. Skipping."
        return 0
    fi

    log_info "Building package: ${BOLD}$pkg_name${NC}..."
    (
        cd "$pkg_dir"
        # Build package without signing, clean srcdir after
        makepkg -sf --noconfirm --needed
        # Move generated packages to repository
        mv -f ./*.pkg.tar.zst "$REPO_DIR/" 2>/dev/null || true
    )
    log_success "Finished build for: $pkg_name"
}

update_database() {
    log_info "Updating repository database at: $REPO_DIR/${DB_NAME}.db.tar.gz"
    shopt -s nullglob
    local PKG_FILES=("$REPO_DIR"/*.pkg.tar.zst)
    shopt -u nullglob

    if [[ ${#PKG_FILES[@]} -eq 0 ]]; then
        log_warn "No .pkg.tar.zst files found in $REPO_DIR to index."
        return 0
    fi

    (
        cd "$REPO_DIR"
        # repo-add creates kaze.db.tar.gz and symlinks kaze.db
        repo-add -n -R "${DB_NAME}.db.tar.gz" ./*.pkg.tar.zst
        # Ensure kaze-local compatibility symlinks
        ln -sf "${DB_NAME}.db" "${DB_NAME}-local.db"
        ln -sf "${DB_NAME}.files" "${DB_NAME}-local.files"
    )
    log_success "Repository database updated with ${#PKG_FILES[@]} package(s)."
}

usage() {
    echo "Usage: $(basename "$0") [--all | <pkg_name>]"
    echo "  --all             Build all packages in pkgs/ and update database"
    echo "  <pkg_name>        Build specific package from pkgs/<pkg_name>"
    echo "  --db-only         Only update the repo database from existing pkgs in repo/x86_64"
    exit 1
}

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
    usage
elif [[ "$TARGET" == "--all" ]]; then
    for dir in "$PKGS_DIR"/*; do
        if [[ -d "$dir" ]]; then
            build_pkg "$dir"
        fi
    done
    update_database
elif [[ "$TARGET" == "--db-only" ]]; then
    update_database
elif [[ -d "$PKGS_DIR/$TARGET" ]]; then
    build_pkg "$PKGS_DIR/$TARGET"
    update_database
else
    log_error "Target '$TARGET' not found in $PKGS_DIR."
    exit 1
fi
