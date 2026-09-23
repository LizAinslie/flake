{ config, lib, pkgs, ... }:

let
  cfg = config.mey.profile;
in
{
  config = lib.mkIf cfg.apps.media {
    environment.systemPackages =
      [ pkgs.vlc ]
      ++ lib.optional cfg.apps.spotify pkgs.spotify;
  };
}
