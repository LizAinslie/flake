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
  ];

  networking.hostName = "toshinya";

  mey.profile = {
    firmware = "bios";
    # Replace with /dev/disk/by-id/ata-… after generate-config if you want.
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

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
