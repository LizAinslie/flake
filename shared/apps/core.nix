{ config, lib, pkgs, ... }:

{
  imports = [
    ./web.nix
    ./social.nix
    ./media.nix
    ./zen.nix
  ];

  environment.systemPackages = with pkgs; [
    openssl
    tailscale
    nmap
  ] ++ lib.optionals config.mey.profile.apps.extras [
    kdePackages.filelight
    obsidian
    zed-editor
  ];
}
