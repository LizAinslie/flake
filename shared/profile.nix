{ lib, ... }:

with lib;

{
  options.mey.profile = {
    firmware = mkOption {
      type = types.enum [ "efi" "bios" ];
      default = "efi";
    };

    grubDevice = mkOption {
      type = types.str;
      default = "nodev";
    };

    kernel = mkOption {
      type = types.enum [ "latest" "lts" ];
      default = "latest";
    };

    desktop = mkOption {
      type = types.enum [ "plasma" "hypr" "plasma+hypr" "i3" "lxqt" "none" ];
      default = "plasma+hypr";
    };

    sessions = mkOption {
      type = types.listOf (types.enum [ "lxqt" "i3-eww" "i3" "plasma" "hypr" ]);
      default = [ ];
    };

    displayManager = mkOption {
      type = types.enum [ "sddm" "lightdm" "greetd" "ly" "none" ];
      default = "sddm";
    };

    browser = mkOption {
      type = types.enum [ "firefox" "librewolf" "falkon" "qutebrowser" "none" ];
      default = "firefox";
    };

    apps = {
      web = mkEnableOption "browser module" // { default = true; };
      zen = mkEnableOption "zen-browser wrapper" // { default = true; };
      chrome = mkEnableOption "Google Chrome" // { default = true; };
      social = mkEnableOption "discord/telegram" // { default = true; };
      media = mkEnableOption "vlc" // { default = true; };
      spotify = mkEnableOption "spotify" // { default = true; };
      extras = mkEnableOption "obsidian/filelight/zed" // { default = true; };
    };
  };
}
