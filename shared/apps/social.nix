{ config, lib, pkgs, ... }:

let
  s = config.mey.profile.apps.social;
in
{
  config = lib.mkIf s.enable {
    environment.systemPackages =
      lib.optional s.discord pkgs.discord
      ++ lib.optional s.telegram pkgs.telegram-desktop;
  };
}
