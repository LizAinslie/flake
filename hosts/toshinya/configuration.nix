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
      web = true;
      zen = false;
      chrome = false;
      social = false;
      media = true;
      spotify = false;
      extras = false;
    };
  };

  # Don't compile vicinae on the E-300.
  nix.settings.extra-substituters = [ "https://vicinae.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
  ];

  system.stateVersion = "26.05";
}
