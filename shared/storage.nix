{ config, pkgs, ... }:

{
  # crypt-keeper itself comes from nix-suite (homeModules.default, via shared/home.nix).
  imports = [
    ./secret-keeper.nix
  ];

  # sops helper + backups. Set drive.uuid once the flash drive exists (lsblk -f).
  services.secret-keeper.enable = true;

  # Removable LUKS vaults (ODD bay, USB). Root unlock is hosts/toshinya/disks.nix.
  nix-suite.crypt-keeper = {
    enable = true;
    drives = [
      {
        alias = "dev";
        uuid = "8f47fc38-3d0f-450b-9d14-fde42518231a";
        mountPoint = "/mnt/dev";
      }
      # ODD-bay vault — fill UUID after you format that disk:
      # {
      #   alias = "vault";
      #   uuid = "REPLACE_VAULT_LUKS_UUID";
      #   mountPoint = "/mnt/vault";
      # }
    ];
  };
}
