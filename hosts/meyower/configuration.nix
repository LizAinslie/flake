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

  # t3code (3773) over LAN only: IPv4 LAN 192.168.68.0/22 + IPv6 link-local. iptables backend.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 3773 -s 192.168.68.0/22 -j nixos-fw-accept
    ip6tables -A nixos-fw -p tcp --dport 3773 -s fe80::/10 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 3773 -s 192.168.68.0/22 -j nixos-fw-accept || true
    ip6tables -D nixos-fw -p tcp --dport 3773 -s fe80::/10 -j nixos-fw-accept || true
  '';

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
