{ ... }:

{
  boot.initrd.luks.devices."luks-toshinya".device =
    "/dev/disk/by-uuid/f7407945-e385-4505-9686-a5a38a16e0aa";

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
    device = "/dev/disk/by-uuid/b4e34e22-1020-4b33-8cb6-d0b2b69edd7e";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/11420961-cd7c-49c0-aa6a-fb32d1ab8df7";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }];
}
