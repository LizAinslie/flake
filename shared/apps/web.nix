{ config, lib, pkgs, ... }:

let
  cfg = config.mey.profile;
in
{
  config = lib.mkIf cfg.apps.web {
    programs.firefox.enable = cfg.browser == "firefox";

    environment.systemPackages =
      lib.optional (cfg.browser == "librewolf") pkgs.librewolf
      ++ lib.optional (cfg.browser == "falkon") pkgs.falkon
      ++ lib.optional (cfg.browser == "qutebrowser") pkgs.qutebrowser
      ++ lib.optional cfg.apps.chrome pkgs.google-chrome;
  };
}
