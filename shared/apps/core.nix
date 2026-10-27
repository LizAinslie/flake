{ config, lib, pkgs, inputs, ... }:

let
  tools = config.mey.profile.apps.tools;
  hibi = import ../../pkgs/hibi.nix { inherit inputs; system = pkgs.stdenv.hostPlatform.system; };
in
{
  imports = [
    ./web.nix
    ./social.nix
    ./media.nix
    ./studio.nix
    ./zen.nix
    ./games.nix
    ./wireguard.nix
    ./ksnip.nix
    ./gpu-screen-recorder.nix
  ];

  environment.systemPackages = with pkgs; [
    openssl
    tailscale
    nmap
  ] ++ lib.optionals tools.enable (
    lib.optional tools.zed zed-editor
    ++ lib.optional tools.obsidian obsidian
    ++ lib.optional tools.hibi hibi.beta
    ++ lib.optional tools.hibi-nightly hibi.nightly
    ++ lib.optional tools.filelight kdePackages.filelight
    ++ lib.optional tools.ksnip ksnip
    ++ lib.optional tools.intiface intiface-central
  );
}
