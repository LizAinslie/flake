{ lib, ... }:

with lib;

let
  flag = desc: mkEnableOption desc // { default = true; };
in
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
      web = {
        enable = flag "web/browser group";
        chrome = flag "Google Chrome";
        zen = flag "Zen Browser";
        tor = flag "Tor Browser";
      };
      social = {
        enable = flag "social group";
        discord = flag "Discord";
        telegram = flag "Telegram";
      };
      media = {
        enable = flag "media group";
        vlc = flag "VLC";
        spotify = flag "Spotify";
      };
      tools = {
        enable = flag "tools group";
        zed = flag "Zed";
        obsidian = flag "Obsidian";
        filelight = flag "Filelight";
      };
      games = {
        enable = mkEnableOption "games group" // { default = false; };
        steam = flag "Steam";
        protonup = flag "protonup-qt";
        gamemode = flag "Feral GameMode";
      };
    };
  };
}
