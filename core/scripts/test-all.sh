#!/usr/bin/env bash
# ==============================================================================
# KAZE OS: MASTER END-TO-END VERIFICATION SUITE (core/scripts/test-all.sh)
# Performs comprehensive dry-run profile synthesis and validation across
# all three Kaze OS distributions (Kasumi, Hayate, and Nagomi).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${CYAN}${BOLD}==================================================================${NC}"
echo -e "${CYAN}${BOLD}       KAZE OS (風) - MASTER END-TO-END VERIFICATION SUITE       ${NC}"
echo -e "${CYAN}${BOLD}==================================================================${NC}\n"

cd "$ROOT_DIR"

# 1. Verify shell script syntax
echo -e "${BLUE}${BOLD}[STEP 1/5] Validating shell scripts syntax...${NC}"
bash -n build.sh
bash -n launch.sh
bash -n core/scripts/verify-profile.sh
bash -n repo/update-repo.sh
bash -n core/archiso/airootfs/usr/local/bin/kaze-live-init
echo -e "${GREEN}  ✓ All shell scripts passed syntax checks.${NC}\n"

# 2. Verify Local Repository Database
echo -e "${BLUE}${BOLD}[STEP 2/5] Validating local package repository database...${NC}"
if [[ ! -f "repo/x86_64/kaze.db.tar.gz" ]]; then
    echo -e "${RED}[ERROR] Local package repository database missing!${NC}" >&2
    exit 1
fi
tar -tzf repo/x86_64/kaze.db.tar.gz > /dev/null
echo -e "${GREEN}  ✓ repo/x86_64/kaze.db.tar.gz valid and indexed.${NC}\n"

# 3. Setup temporary test work directory
TEST_WORK_DIR="${ROOT_DIR}/.test-work"
rm -rf "$TEST_WORK_DIR"
mkdir -p "$TEST_WORK_DIR"
trap 'rm -rf "$TEST_WORK_DIR"' EXIT

# 3. Test Kasumi Profile Synthesis
echo -e "${BLUE}${BOLD}[STEP 3/5] Testing Kaze Kasumi (Aesthetic Wayland Rice)...${NC}"
./build.sh --flavor kasumi --assemble-only --work-dir "$TEST_WORK_DIR" > /dev/null
./core/scripts/verify-profile.sh "$TEST_WORK_DIR/profile"
echo -e "${GREEN}  ✓ Kaze Kasumi profile synthesized and verified successfully.${NC}\n"

# 4. Test Hayate Profile Synthesis
echo -e "${BLUE}${BOLD}[STEP 4/5] Testing Kaze Hayate (Performance & Gaming)...${NC}"
./build.sh --flavor hayate --assemble-only --work-dir "$TEST_WORK_DIR" > /dev/null
./core/scripts/verify-profile.sh "$TEST_WORK_DIR/profile"
echo -e "${GREEN}  ✓ Kaze Hayate profile synthesized and verified successfully.${NC}\n"

# 5. Test Nagomi Profile Synthesis
echo -e "${BLUE}${BOLD}[STEP 5/5] Testing Kaze Nagomi (Daily Driver Workstation)...${NC}"
./build.sh --flavor nagomi --assemble-only --work-dir "$TEST_WORK_DIR" > /dev/null
./core/scripts/verify-profile.sh "$TEST_WORK_DIR/profile"
echo -e "${GREEN}  ✓ Kaze Nagomi profile synthesized and verified successfully.${NC}\n"

echo -e "${GREEN}${BOLD}==================================================================${NC}"
echo -e "${GREEN}${BOLD}  ALL KAZE OS MODULES AND FLAVORS VERIFIED - PRODUCTION READY!   ${NC}"
echo -e "${GREEN}${BOLD}==================================================================${NC}\n"
