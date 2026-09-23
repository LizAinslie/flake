{ config, lib, pkgs, ... }:

let
  p = config.mey.profile;
  web = p.apps.web;
in
{
  config = lib.mkIf web.enable {
    programs.firefox.enable = p.browser == "firefox";

    environment.systemPackages =
      lib.optional (p.browser == "librewolf") pkgs.librewolf
      ++ lib.optional (p.browser == "falkon") pkgs.falkon
      ++ lib.optional (p.browser == "qutebrowser") pkgs.qutebrowser
      ++ lib.optional web.chrome pkgs.google-chrome
      ++ lib.optional web.tor pkgs.tor-browser;
  };
}
