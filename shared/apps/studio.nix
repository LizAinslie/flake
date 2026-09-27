{ config, lib, pkgs, ... }:

let
  s = config.mey.profile.apps.studio;
in
{
  config = lib.mkIf s.enable {
    programs.obs-studio = lib.mkIf s.obs {
      enable = true;
      enableVirtualCamera = true;
    };
  };
}
