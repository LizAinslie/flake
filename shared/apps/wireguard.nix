{ config, lib, pkgs, ... }:

let
  v = config.mey.profile.apps.vpn;
  confDir = v.confDir;

  # Kept out of the indented script: two single quotes would end the Nix string.
  stripKeyQuotes = lib.escapeShellArg "s/^([[:space:]]*(PrivateKey|PresharedKey|PublicKey)[[:space:]]*=[[:space:]]*)[\"']([^\"']*)[\"'][[:space:]]*$/\\1\\3/";

  # Runtime import so private keys never land in the Nix store.
  # nmcli import rejects a PrivateKey that is quoted, CRLF-padded, or not
  # exactly 32-byte base64 ("invalid secret 'PrivateKey'"). Normalize first.
  vpnImport = pkgs.writeShellScriptBin "vpn-import" ''
    set -uo pipefail
    dir="''${VPN_CONF_DIR:-${confDir}}"
    if [[ ! -d "$dir" ]]; then
      echo "vpn-import: $dir does not exist, nothing to import" >&2
      exit 0
    fi
    shopt -s nullglob
    existing="$(nmcli -g NAME connection show || true)"
    failed=0

    normalize_conf() {
      local src=$1 dest=$2
      local key=""
      sed -e $'1s/^\xef\xbb\xbf//' -e 's/\r$//' "$src" \
        | sed -E \
            -e ${stripKeyQuotes} \
            -e 's/&#43;/+/g; s/&plus;/+/g' \
        > "$dest"
      chmod 600 "$dest"

      key=$(awk -F= -v q="'" '
        $1 ~ /^[[:space:]]*PrivateKey[[:space:]]*$/ {
          v = $2
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
          gsub("^[" q "]+|[" q "]+$", "", v)
          gsub(/[[:space:]]/, "", v)
          print v
          exit
        }
      ' "$dest")

      if [[ -z "$key" ]]; then
        echo "vpn-import: $(basename "$dest") has no PrivateKey" >&2
        return 1
      fi
      if ! printf '%s\n' "$key" | wg pubkey >/dev/null 2>&1; then
        echo "vpn-import: $(basename "$dest") PrivateKey is not a WireGuard key (length ''${#key}, expected 44, usually ending in =)." >&2
        echo "vpn-import: NetworkManager reports that as invalid secret 'PrivateKey'. Re-download the conf; do not wrap or quote the key." >&2
        return 1
      fi

      awk -v key="$key" -F= '
        $1 ~ /^[[:space:]]*PrivateKey[[:space:]]*$/ {
          print "PrivateKey = " key
          next
        }
        { print }
      ' "$dest" > "$dest.clean"
      mv "$dest.clean" "$dest"
      chmod 600 "$dest"
    }

    for conf in "$dir"/*.conf; do
      name="$(basename "$conf" .conf)"
      if grep -qxF "$name" <<< "$existing"; then
        continue
      fi
      if (( ''${#name} > 15 )); then
        echo "vpn-import: skip $name.conf (interface name must be 15 characters or fewer)" >&2
        failed=1
        continue
      fi
      tmp=$(mktemp -d)
      chmod 700 "$tmp"
      if ! normalize_conf "$conf" "$tmp/$name.conf"; then
        rm -rf "$tmp"
        failed=1
        continue
      fi
      if ! nmcli connection import type wireguard file "$tmp/$name.conf"; then
        echo "vpn-import: nmcli still rejected $name" >&2
        rm -rf "$tmp"
        failed=1
        continue
      fi
      rm -rf "$tmp"
      nmcli connection modify "$name" \
        connection.autoconnect no \
        connection.interface-name "$name"
      echo "imported $name"
    done
    exit "$failed"
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
        pkgs.gawk
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
