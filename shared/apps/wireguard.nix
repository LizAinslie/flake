{ config, lib, pkgs, ... }:

let
  v = config.mey.profile.apps.vpn;
  confDir = v.confDir;

  # Runtime import so private keys never land in the Nix store.
  vpnImport = pkgs.writeShellScriptBin "vpn-import" ''
    set -euo pipefail
    dir="''${VPN_CONF_DIR:-${confDir}}"
    if [[ ! -d "$dir" ]]; then
      echo "vpn-import: $dir does not exist, nothing to import" >&2
      exit 0
    fi
    shopt -s nullglob
    existing="$(nmcli -g NAME connection show || true)"
    for conf in "$dir"/*.conf; do
      name="$(basename "$conf" .conf)"
      if grep -qxF "$name" <<< "$existing"; then
        continue
      fi
      nmcli connection import type wireguard file "$conf"
      nmcli connection modify "$name" \
        connection.autoconnect no \
        connection.interface-name "$name"
      echo "imported $name"
    done
  '';
in
{
  config = lib.mkIf v.enable {
    environment.systemPackages = [
      pkgs.wireguard-tools
      vpnImport
    ];

    # Client tunnels often trip reverse-path filtering (same fix Tailscale wants).
    networking.firewall.checkReversePath = "loose";

    systemd.services.vpn-import = {
      description = "Import WireGuard configs from ${confDir}";
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      path = [
        pkgs.networkmanager
        pkgs.wireguard-tools
      ];
      environment.VPN_CONF_DIR = confDir;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${vpnImport}/bin/vpn-import";
      };
    };

    systemd.paths.vpn-import = {
      description = "Watch ${confDir} for WireGuard configs";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathExists = confDir;
        PathChanged = confDir;
        Unit = "vpn-import.service";
      };
    };
  };
}
