# Bootloader configuration.
#
# install.sh regenerates this file per machine based on the detected firmware:
#   UEFI → GRUB installed to the removable EFI path (\EFI\BOOT\BOOTX64.EFI),
#          so the system boots without writing NVRAM entries. This works on
#          locked-down firmware, USB-boot media, and VMs alike.
#   BIOS → GRUB embedded on the disk via the GPT BIOS-boot partition.
#
# The committed default below is the UEFI variant.
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
