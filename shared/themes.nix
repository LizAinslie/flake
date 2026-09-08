{ config, pkgs, inputs, ... }:

{
  services.displayManager.sddm.theme = "catppuccin-mocha-mauve";

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  environment.systemPackages = with pkgs; [
    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
      winDecStyles = [ "modern" ]; # "classic" or "modern"
    })
  ];
}
