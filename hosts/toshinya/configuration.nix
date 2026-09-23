{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../../shared/core.nix
    ../../shared/users.nix
    ../../shared/apps/core.nix
    ../../shared/graphics/radeon.nix
    ../../shared/desktops/lxqt.nix
    ../../shared/desktops/i3.nix
    ../../shared/desktops/greetd.nix
    ./hardware.nix
    ./disks.nix
  ];

  networking.hostName = "toshinya";

  mey.profile = {
    firmware = "bios";
    grubDevice = "/dev/sda";
    kernel = "lts";
    desktop = "none";
    sessions = [ "lxqt" "i3-eww" ];
    displayManager = "greetd";
    browser = "librewolf";
    apps = {
      web = {
        enable = true;
        chrome = false;
        zen = false;
        tor = true;
      };
      social.enable = false;
      media = {
        enable = true;
        vlc = true;
        spotify = false;
      };
      tools = {
        enable = true;
        zed = true;
        obsidian = true;
        filelight = false;
      };
      games.enable = false;
    };
  };

  programs.hyprland.enable = lib.mkForce false;

  nix.settings.extra-substituters = [ "https://vicinae.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
  ];

  system.stateVersion = "26.05";
}
