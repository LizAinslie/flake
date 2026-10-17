{ config, pkgs, ... }:

{
  imports = [ ../crypt-keeper.nix ];

  # Removable LUKS vaults (ODD bay, USB). Root unlock is hosts/toshinya/disks.nix.
  services.crypt-keeper = {
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
