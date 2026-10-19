{ config, pkgs, inputs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  # ksnip replaces Spectacle (and frees Print for it).
  environment.plasma6.excludePackages = [ pkgs.kdePackages.spectacle ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
