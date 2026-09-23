{ config, lib, pkgs, ... }:

let
  a = config.mey.profile.apps;
in
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
  ] ++ lib.optional a.zed zed-editor
    ++ lib.optional a.tor tor-browser
    ++ lib.optionals a.extras [
      kdePackages.filelight
      obsidian
    ];
}
