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

  services.displayManager.defaultSession = "plasma";

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/606b9502-0fa5-4b09-9060-f72a2336cf2a";

      # Replaces the manual cryptsetup block completely.
      # Automatically manages ephemeral disk encryption securely on every boot cycle.
      randomEncryption = {
        enable = true;
        allowDiscards = true; # Keeps TRIM active on SSDs/NVMEs safely
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

      # Crucial dependencies that external Java binaries look for
      alsa-lib
      freetype
      fontconfig
      libglvnd
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  system.stateVersion = "26.05";
}
