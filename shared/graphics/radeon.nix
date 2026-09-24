{ ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "modesetting" "radeon" ];
  boot.initrd.kernelModules = [ "radeon" ];
}
