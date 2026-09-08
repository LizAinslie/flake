{ config, pkgs, inputs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    discord
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
