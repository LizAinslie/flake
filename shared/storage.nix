{ config, pkgs, ... }:

{
  imports = [ ../crypt-keeper.nix ];

  services.crypt-keeper = {
    enable = true;
    drives = [
      {
        alias = "dev";
        uuid = "8f47fc38-3d0f-450b-9d14-fde42518231a";
        mountPoint = "/mnt/dev";
      }
      # {
      #   alias = "storage";
      #   uuid = "";
      #   mountPoint = "/mnt/storage";
      # }
    ];
  };
}
