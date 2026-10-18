{ config, lib, pkgs, inputs, ... }:

let
  s = config.mey.profile.apps.social;
  fluxerPkg = inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.fluxer;

  # Upstream's fluxer.desktop points Exec at bin/fluxer-launcher, which isn't
  # in bin/ (it lives in opt/fluxer/), so the menu entry is dead. Own it here.
  fluxerDesktop = pkgs.makeDesktopItem {
    name = "fluxer";
    desktopName = "Fluxer";
    genericName = "Instant Messenger";
    comment = "Instant messaging and VoIP";
    exec = "${fluxerPkg}/bin/fluxer %U";
    icon = "fluxer";
    categories = [ "Network" "InstantMessaging" ];
    mimeTypes = [ "x-scheme-handler/fluxer" ];
    startupWMClass = "fluxer";
  };

  discordDesktop = pkgs.makeDesktopItem {
    name = "discord";
    desktopName = "Discord";
    genericName = "Internet Messenger";
    comment = "All-in-one voice and text chat for gamers";
    exec = "${pkgs.discord}/bin/discord %U";
    icon = "discord";
    categories = [ "Network" "InstantMessaging" ];
    mimeTypes = [ "x-scheme-handler/discord" ];
    startupWMClass = "discord";
  };
in
{
  config = lib.mkIf s.enable {
    # hiPrio: our .desktop files share a filename with the packages' own, so
    # ours must win the buildEnv collision.
    environment.systemPackages =
      lib.optionals s.discord [ pkgs.discord (lib.hiPrio discordDesktop) ]
      ++ lib.optionals s.fluxer [ fluxerPkg (lib.hiPrio fluxerDesktop) ]
      ++ lib.optional s.telegram pkgs.telegram-desktop;
  };
}
