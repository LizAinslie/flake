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
in
{
  config = lib.mkIf web.enable {
    programs.firefox = {
      enable = wantFirefox;
      policies = lib.mkIf wantFirefox policies;
    };

    # LibreWolf reads /etc/librewolf/policies. Tor Browser reads the
    # policies.json baked into its own package, not a symlink farm, so this
    # file is best-effort only. Do not overlay the store path: rm follows
    # those symlinks and the build dies with EACCES.
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
      ++ lib.optional web.tor pkgs.tor-browser;
  };
}
