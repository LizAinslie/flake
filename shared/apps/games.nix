{ config, pkgs, inputs, ... }:

{
  # imports = [
    # inputs.aethermesh.nixosModules.default;
  # ];

  # programs.aethermesh.enable = true;

  environment.systemPackages = with pkgs; [
    # proton-ge-bin
    protonup-qt
    steam
  ];

  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    # Other general flags if available can be set here.
  };

  programs.gamemode.enable = true;
}
