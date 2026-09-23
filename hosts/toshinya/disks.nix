# Fill the three REPLACE_* strings from the installer:
#   lsblk -o NAME,FSTYPE,UUID,PARTUUID
#   blkid /dev/sda2 /dev/sda3 /dev/sda4
# sda2 = /boot UUID, sda3 = swap PARTUUID, sda4 = LUKS UUID (not the btrfs UUID).
{ ... }:

{
  boot.initrd.luks.devices."luks-toshinya" = {
    device = "/dev/disk/by-uuid/REPLACE_LUKS_UUID";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/luks-toshinya";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/luks-toshinya";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/luks-toshinya";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE_BOOT_UUID";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/REPLACE_SWAP_PARTUUID";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];
}
