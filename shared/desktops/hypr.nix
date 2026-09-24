{ config, pkgs, inputs, lib, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nix.settings.extra-substituters = [ "https://hyprland.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
}
