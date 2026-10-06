{ config, lib, pkgs, ... }:

let
  g = config.mey.profile.apps.games;
in
{
  config = lib.mkIf g.enable {
    environment.systemPackages =
      lib.optional g.steam pkgs.steam
      ++ lib.optional g.protonup pkgs.protonup-qt
      ++ lib.optional g.prism pkgs.prismlauncher;

    programs.steam = lib.mkIf g.steam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = g.gamemode;

  };
}
