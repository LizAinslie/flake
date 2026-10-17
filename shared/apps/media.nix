{ config, lib, pkgs, ... }:

let
  m = config.mey.profile.apps.media;
in
{
  config = lib.mkIf m.enable {
    environment.systemPackages =
      lib.optional m.vlc pkgs.vlc
      ++ lib.optional m.spotify pkgs.spotify;
  };
}
