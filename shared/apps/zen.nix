{ config, lib, pkgs, inputs, ... }:

let
  policies = import ./browser-policies.nix { inherit lib; };
in
{
  config = lib.mkIf (config.mey.profile.apps.web.enable && config.mey.profile.apps.web.zen) {
    environment.systemPackages = [
      (pkgs.wrapFirefox
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
        {
          extraPrefs = lib.concatLines (
            lib.mapAttrsToList (
              name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
            ) { }
          );

          extraPolicies = policies;
        }
      )
    ];
  };
}
