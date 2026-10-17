{ config, lib, pkgs, inputs, ... }:

let
  s = config.mey.profile.apps.social;
  fluxerPkg = inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.fluxer;
in
{
  config = lib.mkIf s.enable {
    environment.systemPackages =
      lib.optional s.discord pkgs.discord
      ++ lib.optional s.fluxer fluxerPkg
      ++ lib.optional s.telegram pkgs.telegram-desktop;
  };
}
