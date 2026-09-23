{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mey.profile.apps.social {
    environment.systemPackages = with pkgs; [
      discord
      telegram-desktop
    ];
  };
}
