{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.mt7927.nixosModules.default
    ../../shared/core.nix
    ../../shared/users.nix
    ../../shared/appearance.nix

    ../../shared/apps/core.nix
    ../../shared/apps/dev.nix
    # games.nix / studio.nix / wireguard.nix are pulled in via apps/core.nix and gated on profile flags

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
      social = {
        enable = true;
        discord = true;
        fluxer = true;
      };
      media.enable = true;
      studio.enable = true;
      tools.enable = true;
      games.enable = true;
      vpn.enable = true;
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

  # MediaTek MT7927 (Filogic 380) Wi-Fi 7 + BT 5.4 on Strix X870-F.
  # Out-of-tree patches + firmware until mainline fully supports it.
  hardware.mediatek-mt7927 = {
    enable = true;
    enableWifi = true;
    enableBluetooth = true;
    disableAspm = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
}
