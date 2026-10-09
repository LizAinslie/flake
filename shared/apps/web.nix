{ config, lib, pkgs, ... }:

let
  p = config.mey.profile;
  web = p.apps.web;
  policies = import ./browser-policies.nix { inherit lib; };
  policiesJson = pkgs.writeText "browser-policies.json" (builtins.toJSON {
    policies = policies // {
      DisableAppUpdate = true;
    };
  });
  wantFirefox = web.firefox || p.browser == "firefox";
  wantLibreWolf = p.browser == "librewolf";

  # Tor Browser ships its own distribution/policies.json. Overlay ours beside
  # the real install dir when that directory exists; also drop a copy where
  # Firefox-based builds look under /etc.
  torBrowser = pkgs.runCommand "tor-browser-with-policies" { } ''
    mkdir -p $out/bin $out/share
    ln -s ${pkgs.tor-browser}/bin/tor-browser $out/bin/tor-browser
    if [[ -d ${pkgs.tor-browser}/share ]]; then
      ln -s ${pkgs.tor-browser}/share/* $out/share/ || true
    fi
    dist=$(find ${pkgs.tor-browser} -type d -name distribution -print -quit || true)
    if [[ -n "$dist" ]]; then
      rel="''${dist#${pkgs.tor-browser}/}"
      rm -rf "$out/$rel"
      mkdir -p "$out/$rel"
      if [[ -d "$dist" ]]; then
        ln -s "$dist"/* "$out/$rel/" || true
      fi
      rm -f "$out/$rel/policies.json"
      ln -s ${policiesJson} "$out/$rel/policies.json"
    fi
  '';
in
{
  config = lib.mkIf web.enable {
    programs.firefox = {
      enable = wantFirefox;
      policies = lib.mkIf wantFirefox policies;
    };

    environment.etc = lib.mkMerge [
      (lib.mkIf wantLibreWolf {
        "librewolf/policies/policies.json".source = policiesJson;
      })
      (lib.mkIf web.tor {
        "tor-browser/policies/policies.json".source = policiesJson;
      })
    ];

    environment.systemPackages =
      lib.optional wantLibreWolf pkgs.librewolf
      ++ lib.optional (p.browser == "falkon") pkgs.falkon
      ++ lib.optional (p.browser == "qutebrowser") pkgs.qutebrowser
      ++ lib.optional web.chrome pkgs.google-chrome
      ++ lib.optional web.tor torBrowser;
  };
}
