{ lib, config, pkgs, ... }:

let
  sessions = config.mey.profile.sessions;
  wantedI3 =
    builtins.elem "i3" sessions
    || builtins.elem "i3-eww" sessions
    || config.mey.profile.desktop == "i3";
  wantedEww = builtins.elem "i3-eww" sessions;
in
{
  config = lib.mkIf wantedI3 {
    services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
        dmenu
      ] ++ lib.optional wantedEww eww;
    };

    services.xserver.displayManager.session = lib.mkIf wantedEww [
      {
        manage = "window";
        name = "i3-eww";
        start = ''
          ${pkgs.eww}/bin/eww daemon &
          exec ${pkgs.i3}/bin/i3
        '';
      }
    ];
  };
}
