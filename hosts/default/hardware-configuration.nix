# ─────────────────────────────────────────────────────────────────────────────
#  hardware-configuration.nix — PLACEHOLDER STUB
# ─────────────────────────────────────────────────────────────────────────────
#  This file is intentionally a stub. Hardware configuration is machine-specific
#  (disk UUIDs, partition layout, kernel modules, CPU microcode, etc.) and must
#  NOT be copied between machines.
#
#  Before you build this flake, REGENERATE this file for your own hardware:
#
#      sudo nixos-generate-config --show-hardware-config \
#        > hosts/default/hardware-configuration.nix
#
#  (or let the included install.sh do it for you during a fresh install).
#
#  The real file defines at minimum:
#    • boot.initrd.availableKernelModules / boot.kernelModules
#    • fileSystems."/"     — your root device (by-uuid)
#    • fileSystems."/boot" — your EFI/boot device (by-uuid)
#    • swapDevices
#    • nixpkgs.hostPlatform
#    • hardware.cpu.<vendor>.updateMicrocode
#
#  The empty definitions below let the flake parse, but it will NOT boot until
#  you replace this with your machine's generated configuration.
# ─────────────────────────────────────────────────────────────────────────────
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # REPLACE everything below with `nixos-generate-config` output for your machine.
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-ROOT-UUID";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-BOOT-UUID";
  #   fsType = "vfat";
  #   options = [ "fmask=0077" "dmask=0077" ];
  # };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode   = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
