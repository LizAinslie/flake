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
      {
        Name = "npm";
        URLTemplate = "https://www.npmjs.com/search?q={searchTerms}";
        IconURL = "https://www.npmjs.com/favicon.ico";
        Alias = "@npm";
      }
      {
        Name = "GitHub";
        URLTemplate = "https://github.com/search?q={searchTerms}";
        IconURL = "https://github.com/favicon.ico";
        Alias = "@gh";
      }
      {
        Name = "klibs.io";
        URLTemplate = "https://klibs.io/?q={searchTerms}";
        IconURL = "https://klibs.io/favicon.ico";
        Alias = "@kl";
      }
      {
        Name = "JSR";
        URLTemplate = "https://jsr.io/packages?search={searchTerms}";
        IconURL = "https://jsr.io/favicon.ico";
        Alias = "@jsr";
      }
      {
        Name = "docs.rs";
        URLTemplate = "https://docs.rs/releases/search?query={searchTerms}";
        IconURL = "https://docs.rs/favicon.ico";
        Alias = "@drs";
      }
      {
        Name = "crates.io";
        URLTemplate = "https://crates.io/search?q={searchTerms}";
        IconURL = "https://crates.io/favicon.ico";
        Alias = "@crate";
      }
      {
        Name = "Maven Repository";
        URLTemplate = "https://mvnrepository.com/search?q={searchTerms}";
        IconURL = "https://mvnrepository.com/favicon.ico";
        Alias = "@mvn";
      }
      {
        Name = "hex.pm";
        URLTemplate = "https://hex.pm/packages?search={searchTerms}";
        IconURL = "https://hex.pm/favicon.ico";
        Alias = "@hex";
      }
      {
        Name = "Docker Hub";
        URLTemplate = "https://hub.docker.com/search?q={searchTerms}";
        IconURL = "https://hub.docker.com/favicon.ico";
        Alias = "@dh";
      }
      {
        Name = "MDN";
        URLTemplate = "https://developer.mozilla.org/en-US/search?q={searchTerms}";
        IconURL = "https://developer.mozilla.org/favicon.ico";
        Alias = "@mdn";
      }
      {
        Name = "Stack Overflow";
        URLTemplate = "https://stackoverflow.com/search?q={searchTerms}";
        IconURL = "https://stackoverflow.com/favicon.ico";
        Alias = "@so";
      }
      {
        Name = "cppreference";
        URLTemplate = "https://en.cppreference.com/mwiki/index.php?title=Special:Search&search={searchTerms}";
        IconURL = "https://en.cppreference.com/favicon.ico";
        Alias = "@cpp";
      }
      {
        Name = "Arch Wiki";
        URLTemplate = "https://wiki.archlinux.org/index.php?search={searchTerms}";
        IconURL = "https://wiki.archlinux.org/favicon.ico";
        Alias = "@aw";
      }
      {
        Name = "Arch packages";
        URLTemplate = "https://archlinux.org/packages/?q={searchTerms}";
        IconURL = "https://archlinux.org/static/favicon.png";
        Alias = "@ap";
      }
      {
        Name = "AUR";
        URLTemplate = "https://aur.archlinux.org/packages?K={searchTerms}";
        IconURL = "https://aur.archlinux.org/static/images/favicon.png";
        Alias = "@aur";
      }
      {
        Name = "ProtonDB";
        URLTemplate = "https://www.protondb.com/search?q={searchTerms}";
        IconURL = "https://www.protondb.com/favicon.ico";
        Alias = "@pdb";
      }
      {
        Name = "SteamDB";
        URLTemplate = "https://steamdb.info/search/?a=app&q={searchTerms}";
        IconURL = "https://steamdb.info/favicon.ico";
        Alias = "@sdb";
      }
    ];
  };
}
