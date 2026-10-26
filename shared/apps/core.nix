{ config, lib, pkgs, inputs, ... }:

let
  tools = config.mey.profile.apps.tools;
  hibiPkg = inputs.hibi.packages.${pkgs.stdenv.hostPlatform.system}.hibi;
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
    ++ lib.optional tools.hibi hibiPkg
    ++ lib.optional tools.filelight kdePackages.filelight
    ++ lib.optional tools.ksnip ksnip
    ++ lib.optional tools.intiface intiface-central
  );
}
