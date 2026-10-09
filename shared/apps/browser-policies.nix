{ lib, ... }:

# Enterprise policies used by every Firefox-based browser we wrap.
# Falkon, qutebrowser, and Chrome do not read this file.
{
  DisableTelemetry = true;
  DisableFirefoxStudies = true;

  ExtensionSettings = {
    "{9a41dee2-b924-4161-a971-7fb35c053a4a}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhanced-h264ify/latest.xpi";
      installation_mode = "force_installed";
    };
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
    "plasma-browser-integration@kde.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
      installation_mode = "force_installed";
    };
    "sponsorBlocker@ajay.app" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      installation_mode = "force_installed";
    };
    "shinigamieyes@shinigamieyes" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/shinigami-eyes/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  EncryptedMediaExtensions = {
    enabled = true;
    locked = true;
  };

  SearchEngines = {
    Default = "ddg";
    Add = [
      {
        Name = "nixpkgs packages";
        URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
        IconURL = "https://wiki.nixos.org/favicon.ico";
        Alias = "@np";
      }
      {
        Name = "NixOS options";
        URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
        IconURL = "https://wiki.nixos.org/favicon.ico";
        Alias = "@no";
      }
      {
        Name = "NixOS Wiki";
        URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
        IconURL = "https://wiki.nixos.org/favicon.ico";
        Alias = "@nw";
      }
      {
        Name = "noogle";
        URLTemplate = "https://noogle.dev/q?term={searchTerms}";
        IconURL = "https://noogle.dev/favicon.ico";
        Alias = "@ng";
      }
    ];
  };
}
