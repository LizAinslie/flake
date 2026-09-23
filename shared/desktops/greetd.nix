{ lib, config, pkgs, ... }:

let
  p = config.mey.profile;
  sessionRoot = "${config.services.displayManager.sessionData.desktops}";
  tuigreet = lib.getExe pkgs.tuigreet;
in
{
  config = lib.mkIf (p.displayManager == "greetd") {
    services.xserver.displayManager.startx.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            tuigreet
            "--time"
            "--remember"
            "--remember-session"
            "--sessions"
            "${sessionRoot}/share/xsessions:${sessionRoot}/share/wayland-sessions"
          ];
          user = "greeter";
        };
      };
    };

    environment.systemPackages = [ pkgs.tuigreet ];
  };
}
