# Kernel modules only. Filesystems + LUKS + swap live in ./disks.nix
# (do not dump nixos-generate-config over this or you'll duplicate /).
#
# Harvest UUIDs on the installer with:
#   sudo nixos-generate-config --root /mnt --show-hardware-config
# then copy UUID/PARTUUID values into disks.nix REPLACE_* fields.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" "r8169" ];
  # E-300 has no AES-NI; keep software aes/xts in initrd for LUKS.
  boot.initrd.kernelModules = [ "dm_mod" "dm_crypt" "aes" "xts" "sha256" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
