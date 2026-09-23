# Overwrite this file on the installer:
#   sudo nixos-generate-config --root /mnt --show-hardware-config \
#     > /mnt/etc/nixos/hosts/toshinya/hardware.nix
# Then:
#   - prefer /dev/disk/by-id/… or by-partuuid over /dev/sdX
#   - add compress=zstd:1,noatime on btrfs mounts
#   - move swap to configuration.nix as randomEncryption (do not leave plain swap)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" "r8169" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
