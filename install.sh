#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  install.sh — NixOS Hyprland Rice Installer (single-user)
#  Run from any NixOS live ISO as root. Download first — the installer is
#  interactive, so do NOT pipe it into bash (that steals stdin):
#    curl -fsSL <raw-url>/install.sh -o install.sh
#    sudo bash install.sh
#
#  Set FLAKE_REPO to your own fork before running, e.g.:
#    FLAKE_REPO=https://github.com/<you>/nixos-rice sudo -E bash install.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Stable NixOS ISOs ship with flakes disabled — force-enable so nix-command,
# nixos-install --flake, etc. all work without per-command flags.
export NIX_CONFIG="experimental-features = nix-command flakes"

# Git repo to clone the flake from. Override via the FLAKE_REPO env var.
FLAKE_REPO="${FLAKE_REPO:-https://github.com/JagHack/nixos-rice}"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[0;34m'; CYN='\033[0;36m'; BLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${GRN}[✓]${NC} $*"; }
warn()    { echo -e "${YLW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }
header()  { echo -e "\n${BLD}${BLU}━━━ $* ━━━${NC}"; }
confirm() { echo -e "${YLW}[?]${NC} $* [y/N]: "; read -r _a; [[ "${_a,,}" == "y" ]]; }

trap 'echo -e "\n${RED}[✗] Failed at line $LINENO${NC}" >&2' ERR

[[ $EUID -eq 0 ]] || die "Run as root: sudo bash install.sh"

# ─────────────────────────────────────────────────────────────────────────────
clear
echo -e "${BLD}${CYN}"
cat << 'BANNER'
  ╔═══════════════════════════════════════════════╗
  ║        NixOS Hyprland Rice — Installer        ║
  ╚═══════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# ─────────────────────────────────────────────────────────────────────────────
header "Installing Tools"
# ─────────────────────────────────────────────────────────────────────────────
echo "  Installing git, python3, pciutils..."
# python3 is required by the nvidia/flake patches below and is NOT guaranteed
# on the minimal ISO; pciutils gives reliable GPU detection.
nix-env -iA nixpkgs.git nixpkgs.python3 nixpkgs.pciutils -Q 2>/dev/null \
    || nix-env -iA nixos.git nixos.python3 nixos.pciutils -Q
info "Tools ready"

# ─────────────────────────────────────────────────────────────────────────────
header "Machine Setup"
# ─────────────────────────────────────────────────────────────────────────────
echo -n "  Hostname for this machine [nixos]: "
read -r MACHINE_HOST
MACHINE_HOST="${MACHINE_HOST:-nixos}"
info "Hostname: $MACHINE_HOST"

# ─────────────────────────────────────────────────────────────────────────────
header "Firmware Detection"
# ─────────────────────────────────────────────────────────────────────────────
if [[ -d /sys/firmware/efi/efivars ]]; then
    FIRMWARE="uefi"; info "UEFI firmware detected"
else
    FIRMWARE="bios"; warn "Legacy BIOS firmware detected (no EFI)"
fi

# ─────────────────────────────────────────────────────────────────────────────
header "Disk Selection"
# ─────────────────────────────────────────────────────────────────────────────
echo "  Available disks:"
echo
lsblk -d -o NAME,SIZE,MODEL,TRAN --noheadings \
    | grep -Ev "^(loop|sr|fd|zram)" \
    | while read -r name size model tran; do
        printf "    ${BLD}/dev/%-14s${NC}  %-8s  %s  (%s)\n" \
               "$name" "$size" "$model" "$tran"
      done
echo
echo -n "  Enter disk (e.g. sda, nvme0n1, vda): /dev/"
read -r DISK_NAME
DISK="/dev/${DISK_NAME}"
[[ -b "$DISK" ]] || die "Device $DISK not found"
echo
lsblk "$DISK"

# ─────────────────────────────────────────────────────────────────────────────
header "Swap"
# ─────────────────────────────────────────────────────────────────────────────
RAM_GB=$(awk '/MemTotal/ { printf "%.0f", $2/1024/1024 }' /proc/meminfo)
echo "  System RAM: ${RAM_GB} GB"
echo -n "  Swap size in GB (0 = none, Enter = match RAM [${RAM_GB}GB]): "
read -r SWAP_INPUT
if   [[ -z "$SWAP_INPUT" ]];              then SWAP_GB="$RAM_GB"
elif [[ "$SWAP_INPUT" =~ ^[0-9]+$ ]];    then SWAP_GB="$SWAP_INPUT"
else die "Invalid swap size"; fi
info "Swap: ${SWAP_GB} GB"

# ─────────────────────────────────────────────────────────────────────────────
# Partition naming: disks ending in a digit (nvme0n1, mmcblk0) use 'p' prefix
# ─────────────────────────────────────────────────────────────────────────────
[[ "$DISK_NAME" =~ [0-9]$ ]] && P="${DISK}p" || P="${DISK}"

# Partition 1 is firmware-specific:
#   UEFI → 512 MB FAT32 EFI System Partition (mounted at /boot)
#   BIOS →   1 MB unformatted BIOS-boot partition (GRUB embeds its core here)
PART_BOOT="${P}1"
if [[ "$FIRMWARE" == "uefi" ]]; then BOOT_END_MIB=512; else BOOT_END_MIB=2; fi

if [[ "$SWAP_GB" -gt 0 ]]; then
    PART_SWAP="${P}2"; PART_ROOT="${P}3"
else
    PART_ROOT="${P}2"
fi

# ─────────────────────────────────────────────────────────────────────────────
header "Partition Plan — ${RED}ALL DATA ON $DISK WILL BE ERASED${NC}"
# ─────────────────────────────────────────────────────────────────────────────
echo
if [[ "$FIRMWARE" == "uefi" ]]; then
    echo -e "  ${PART_BOOT}  →  512 MB    EFI        (FAT32)"
else
    echo -e "  ${PART_BOOT}  →  1 MB      BIOS boot  (GRUB)"
fi
[[ "$SWAP_GB" -gt 0 ]] && echo -e "  ${PART_SWAP}  →  ${SWAP_GB} GB      Swap"
echo -e "  ${PART_ROOT}  →  rest       Root       (ext4)"
echo
confirm "  Erase $DISK and continue?" || die "Aborted"

# ─────────────────────────────────────────────────────────────────────────────
header "Partitioning"
# ─────────────────────────────────────────────────────────────────────────────
wipefs -af "$DISK"
parted -s "$DISK" mklabel gpt

# Partition 1: EFI System Partition (UEFI) or BIOS-boot partition (BIOS)
if [[ "$FIRMWARE" == "uefi" ]]; then
    parted -s "$DISK" mkpart ESP fat32 1MiB "${BOOT_END_MIB}MiB" set 1 esp on
else
    parted -s "$DISK" mkpart BIOSBOOT 1MiB "${BOOT_END_MIB}MiB" set 1 bios_grub on
fi

# Remaining partitions: optional swap, then root
if [[ "$SWAP_GB" -gt 0 ]]; then
    SWAP_END=$(( BOOT_END_MIB + SWAP_GB * 1024 ))
    parted -s "$DISK" \
        mkpart swap linux-swap "${BOOT_END_MIB}MiB" "${SWAP_END}MiB" \
        mkpart root ext4        "${SWAP_END}MiB"     100%
else
    parted -s "$DISK" mkpart root ext4 "${BOOT_END_MIB}MiB" 100%
fi

sleep 2; partprobe "$DISK" 2>/dev/null || true; sleep 1
info "Partitions created"

# ─────────────────────────────────────────────────────────────────────────────
header "Formatting"
# ─────────────────────────────────────────────────────────────────────────────
# BIOS-boot partition stays raw (GRUB embeds into it) — only the ESP is formatted
if [[ "$FIRMWARE" == "uefi" ]]; then
    mkfs.fat -F32 -n EFI "$PART_BOOT";  info "EFI:  $PART_BOOT"
fi

if [[ "$SWAP_GB" -gt 0 ]]; then
    mkswap -L swap "$PART_SWAP"
    swapon         "$PART_SWAP"
    info "Swap: $PART_SWAP"
fi

mkfs.ext4 -L nixos -F "$PART_ROOT";  info "Root: $PART_ROOT"

# ─────────────────────────────────────────────────────────────────────────────
header "Mounting"
# ─────────────────────────────────────────────────────────────────────────────
mount "$PART_ROOT" /mnt
if [[ "$FIRMWARE" == "uefi" ]]; then
    mkdir -p /mnt/boot
    mount "$PART_BOOT" /mnt/boot
fi
info "Mounted at /mnt"

# ─────────────────────────────────────────────────────────────────────────────
header "Hardware Configuration"
# ─────────────────────────────────────────────────────────────────────────────
nixos-generate-config --root /mnt
info "Generated hardware-configuration.nix"

# ─────────────────────────────────────────────────────────────────────────────
header "Cloning Config"
# ─────────────────────────────────────────────────────────────────────────────
FLAKE_DIR="/tmp/nixos-rice-public"
rm -rf "$FLAKE_DIR"
git clone "$FLAKE_REPO" "$FLAKE_DIR"
info "Cloned $FLAKE_REPO"

# ─────────────────────────────────────────────────────────────────────────────
header "Configuring Host: $MACHINE_HOST"
# ─────────────────────────────────────────────────────────────────────────────

# If this is a new machine name, create a new host dir from the default template
# and add a matching nixosConfigurations.<host> entry to flake.nix.
if [[ "$MACHINE_HOST" != "default" ]]; then
    cp -r "${FLAKE_DIR}/hosts/default" "${FLAKE_DIR}/hosts/${MACHINE_HOST}"

    python3 - "${FLAKE_DIR}/flake.nix" "$MACHINE_HOST" << 'PYEOF'
import sys

path, host = sys.argv[1], sys.argv[2]
text = open(path).read()

block = f"""
    nixosConfigurations.{host} = nixpkgs.lib.nixosSystem {{
      system = "x86_64-linux";
      specialArgs = {{ inherit inputs; }};
      modules = [
        ./hosts/{host}/configuration.nix

        home-manager.nixosModules.home-manager
        {{
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {{ inherit inputs; }};
          home-manager.backupFileExtension = "hm-bak";
          home-manager.users.jaghack = import ./home/default/home.nix;
        }}
      ];
    }};"""

# Insert before the closing of the outputs attrset
text = text.replace('\n  };\n}', f'{block}\n  }};\n}}', 1)
open(path, 'w').write(text)
print(f"  Added nixosConfigurations.{host} to flake.nix")
PYEOF
    info "New host '$MACHINE_HOST' created from default template"
    HOST_DIR="${FLAKE_DIR}/hosts/${MACHINE_HOST}"
    FLAKE_TARGET="$MACHINE_HOST"
else
    HOST_DIR="${FLAKE_DIR}/hosts/default"
    FLAKE_TARGET="default"
fi

# Plug in the real hardware config generated for this machine
cp /mnt/etc/nixos/hardware-configuration.nix \
   "${HOST_DIR}/hardware-configuration.nix"
info "hardware-configuration.nix updated"

# Update hostname in configuration.nix
sed -i "s/networking.hostName = \"[^\"]*\"/networking.hostName = \"${MACHINE_HOST}\"/" \
    "${HOST_DIR}/configuration.nix"
info "Hostname set to $MACHINE_HOST"

# ─────────────────────────────────────────────────────────────────────────────
header "Bootloader (${FIRMWARE})"
# ─────────────────────────────────────────────────────────────────────────────
# Regenerate bootloader.nix for this machine's firmware so it boots anywhere.
if [[ "$FIRMWARE" == "uefi" ]]; then
    cat > "${HOST_DIR}/bootloader.nix" << 'BLEOF'
# Auto-generated by install.sh — UEFI machine.
# GRUB is installed to the removable EFI path (\EFI\BOOT\BOOTX64.EFI) so the
# system boots without writing NVRAM entries — works on locked-down firmware,
# USB media, and VMs alike.
{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
BLEOF
else
    cat > "${HOST_DIR}/bootloader.nix" << BLEOF
# Auto-generated by install.sh — legacy BIOS machine.
# GRUB is embedded on the disk via this GPT disk's BIOS-boot partition.
{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "${DISK}";
    efiSupport = false;
  };
}
BLEOF
fi
info "bootloader.nix generated for ${FIRMWARE}"

# ─────────────────────────────────────────────────────────────────────────────
header "GPU Detection"
# ─────────────────────────────────────────────────────────────────────────────
GPU_INFO=$(lspci 2>/dev/null | grep -iE "vga|3d|display" || true)
echo "  Detected: ${GPU_INFO:-nothing found}"

CONF="${HOST_DIR}/configuration.nix"

if echo "$GPU_INFO" | grep -qi "nvidia"; then
    info "NVIDIA GPU — keeping nvidia config"
else
    warn "No NVIDIA GPU — patching out nvidia block"
    python3 - "$CONF" << 'PYEOF'
import re, sys

path = sys.argv[1]
text = open(path).read()

# Remove nvidia comment + multi-line hardware.nvidia = { ... }; block
text = re.sub(
    r'[ \t]*#[^\n]*[Nn]vidia[^\n]*\n'
    r'[ \t]*hardware\.nvidia\s*=\s*\{[^}]*\};\n',
    '', text, flags=re.DOTALL
)
# Remove standalone nvidia lines
text = re.sub(r'[ \t]*hardware\.graphics\.enable\s*=\s*true;\n', '', text)
text = re.sub(r'[ \t]*services\.xserver\.videoDrivers\s*=\s*\[.*?"nvidia".*?\];\n', '', text)

# Re-add generic graphics.enable before nix-ld section
text = text.replace(
    '  # ── nix-ld',
    '  hardware.graphics.enable = true;\n\n  # ── nix-ld',
    1
)

open(path, 'w').write(text)
print("  Patched: nvidia removed, generic graphics.enable kept")
PYEOF
    info "Patched"
fi

# ─────────────────────────────────────────────────────────────────────────────
header "Staging Config"
# ─────────────────────────────────────────────────────────────────────────────
# Flakes only see git-tracked files, so stage + commit BEFORE installing —
# otherwise the freshly written hardware-configuration.nix / bootloader.nix
# (and any new host dir) are invisible to `nixos-install --flake`.
git -C "$FLAKE_DIR" config user.email 'nixos@localhost'
git -C "$FLAKE_DIR" config user.name  'nixos-installer'
git -C "$FLAKE_DIR" add -A
git -C "$FLAKE_DIR" commit -m "hardware: add host ${MACHINE_HOST}" >/dev/null
info "Config committed locally"

# ─────────────────────────────────────────────────────────────────────────────
header "Installing NixOS"
# ─────────────────────────────────────────────────────────────────────────────
warn "Downloading packages — grab a coffee, this takes a few minutes..."
echo

nixos-install \
    --root /mnt \
    --flake "${FLAKE_DIR}#${FLAKE_TARGET}" \
    --no-root-passwd

# ─────────────────────────────────────────────────────────────────────────────
# Copy flake into ~/nixos-config on the installed system
# ─────────────────────────────────────────────────────────────────────────────
cp -r "$FLAKE_DIR" /mnt/home/jaghack/nixos-config

JAGHACK_UID=$(grep "^jaghack:" /mnt/etc/passwd | cut -d: -f3 || echo "1000")
JAGHACK_GID=$(grep "^jaghack:" /mnt/etc/passwd | cut -d: -f4 || echo "100")
chown -R "${JAGHACK_UID}:${JAGHACK_GID}" /mnt/home/jaghack/nixos-config
info "Config placed at ~/nixos-config"

# ─────────────────────────────────────────────────────────────────────────────
echo
echo -e "${BLD}${GRN}"
cat << 'DONE'
  ╔═══════════════════════════════════════════════╗
  ║         Installation Complete! ✓             ║
  ╚═══════════════════════════════════════════════╝
DONE
echo -e "${NC}"
echo -e "  ${BLD}Login:${NC}   greetd + tuigreet → user 'jaghack'"
echo -e "  ${BLD}Config:${NC}  ~/nixos-config"
echo
echo -e "  ${BLD}${CYN}After first login:${NC}"
echo
echo -e "  ${YLW}# Set a real password (initialPassword is 'changeme'):${NC}"
echo    "  passwd"
echo
echo -e "  ${YLW}# Fritz!Box credentials (optional, for the reconnect script):${NC}"
echo    "  echo 'FRITZ_USER=x'     > ~/.config/hypr/scripts/.env"
echo    "  echo 'FRITZ_PASSWORD=x' >> ~/.config/hypr/scripts/.env"
echo
echo -e "  ${YLW}# Adjust monitors for this machine:${NC}"
echo    "  nvim ~/nixos-config/home/default/dotfiles/hypr/monitors.lua"
echo    "  sudo nixos-rebuild switch --flake ~/nixos-config#${FLAKE_TARGET}"
echo
echo -e "  ${YLW}# Rollback if anything breaks:${NC}"
echo    "  Reboot → GRUB → NixOS generations → pick previous"
echo

confirm "Reboot now?" && reboot || echo "Run 'reboot' when ready."
