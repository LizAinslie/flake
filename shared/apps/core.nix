{ config, lib, pkgs, ... }:

let
  tools = config.mey.profile.apps.tools;
in
{
  imports = [
    ./web.nix
    ./social.nix
    ./media.nix
    ./zen.nix
    ./games.nix
  ];

  environment.systemPackages = with pkgs; [
    openssl
    tailscale
    nmap
  ] ++ lib.optionals tools.enable (
    lib.optional tools.zed zed-editor
    ++ lib.optional tools.obsidian obsidian
    ++ lib.optional tools.filelight kdePackages.filelight
  );
}
