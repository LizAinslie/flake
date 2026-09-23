{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../shared/core.nix
    ../../shared/users.nix
    ../../shared/appearance.nix

    ../../shared/apps/core.nix
    ../../shared/apps/dev.nix
    ../../shared/apps/games.nix

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
      web = true;
      zen = true;
      chrome = true;
      social = true;
      media = true;
      spotify = true;
      zed = true;
      tor = true;
      obsidian = true;
      extras = true;
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
