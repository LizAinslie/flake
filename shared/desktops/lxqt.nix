{ lib, config, ... }:

let
  wanted =
    builtins.elem "lxqt" config.mey.profile.sessions
    || config.mey.profile.desktop == "lxqt";
in
{
  config = lib.mkIf wanted {
    services.xserver.desktopManager.lxqt.enable = true;
  };
}
