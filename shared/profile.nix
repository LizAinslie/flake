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
        discord = mkEnableOption "Discord" // { default = false; };
        fluxer = flag "Fluxer";
        telegram = flag "Telegram";
      };
      media = {
        enable = flag "media group";
        vlc = flag "VLC";
        spotify = flag "Spotify";
      };
      studio = {
        enable = mkEnableOption "media production / recording / streaming" // { default = false; };
        obs = flag "OBS Studio";
        kdenlive = flag "Kdenlive";
        resolve = flag "DaVinci Resolve (free)";
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
        protonGe = flag "Proton GE 10 (GE-Proton10-34)";
        protonup = flag "protonup-qt";
        gamemode = flag "Feral GameMode";
      };
      vpn = {
        enable = flag "WireGuard, importing confs from ~/vpns";
        confDir = mkOption {
          type = types.str;
          default = "/home/mey/vpns";
          description = "Directory of WireGuard .conf files imported into NetworkManager.";
        };
      };
    };
  };
}
