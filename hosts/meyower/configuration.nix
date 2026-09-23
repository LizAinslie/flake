{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../shared/core.nix
    ../../shared/users.nix
    ../../shared/appearance.nix

    ../../shared/apps/core.nix
    ../../shared/apps/dev.nix
    # games.nix is pulled in via apps/core.nix and gated on apps.games.enable

    ../../shared/graphics/nvidia.nix

    ../../shared/desktops/kde.nix
    ../../shared/desktops/hypr.nix

    ./hardware.nix
  ];

  networking.hostName = "meyower";

  mey.profile = {
    firmware = "efi";
    grubDevice = "nodev";
    kernel = "latest";
    desktop = "plasma+hypr";
    sessions = [ "plasma" "hypr" ];
    displayManager = "sddm";
    browser = "firefox";
    apps = {
      web.enable = true;
      social.enable = true;
      media.enable = true;
      tools.enable = true;
      games.enable = true;
    };
  };

  services.displayManager.defaultSession = "plasma";

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/606b9502-0fa5-4b09-9060-f72a2336cf2a";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];

  environment.systemPackages = with pkgs; [
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      glib
      xorg.libX11
      alsa-lib
      freetype
      fontconfig
      libglvnd
    ];
  };

  system.stateVersion = "26.05";
}
