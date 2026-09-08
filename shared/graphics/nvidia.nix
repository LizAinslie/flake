{ config, lib, pkgs, modulesPath, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for 32-bit gaming wrappers/Wine tools
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    # Enable the desktop context settings control dashboard application
    nvidiaSettings = true;

    # Pin the package generation type to the current stable target channel
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
