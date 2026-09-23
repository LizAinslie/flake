{ lib, config, pkgs, ... }:

let
  p = config.mey.profile;
  sessionRoot = "${config.services.displayManager.sessionData.desktops}";
in
{
  config = lib.mkIf (p.displayManager == "greetd") {
    services.xserver.displayManager.startx.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--time"
            "--remember"
            "--remember-session"
            "--sessions"
            "${sessionRoot}/share/wayland-sessions"
            "--xsessions"
            "${sessionRoot}/share/xsessions"
          ];
          user = "greeter";
        };
      };
    };

    environment.systemPackages = [ pkgs.tuigreet pkgs.xorg.xinit ];
  };
}
