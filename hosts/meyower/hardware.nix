{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci_prom21" "ahci" "xhci_pci" "thunderbolt" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/luks-dfcc2136-3380-42b5-824f-a355a32654ff";
      fsType = "btrfs";
    };

  boot.initrd.luks.devices."luks-dfcc2136-3380-42b5-824f-a355a32654ff".device = "/dev/disk/by-uuid/dfcc2136-3380-42b5-824f-a355a32654ff";

  fileSystems."/nix" =
    { device = "/dev/mapper/luks-dfcc2136-3380-42b5-824f-a355a32654ff";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/luks-dfcc2136-3380-42b5-824f-a355a32654ff";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/96BE-5D47";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
