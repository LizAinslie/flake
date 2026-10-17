{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.crypt-keeper;

  driveModule = types.submodule {
    options = {
      alias = mkOption { type = types.str; description = "Short identifier."; };
      uuid = mkOption { type = types.str; description = "The crypto_LUKS UUID."; };
      mountPoint = mkOption { type = types.str; description = "Target directory path."; };
      extraMountOptions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional mount flags (e.g., [ \"noexec\" ]) appended to the baseline.";
      };
    };
  };
in {
  options.services.crypt-keeper = {
    enable = mkEnableOption "Secure on-demand storage management tool";
    drives = mkOption {
      type = types.listOf driveModule;
      default = [];
      description = "Declarative table of your encrypted drives";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "crypt-keeper" ''
        set -euo pipefail

        ACTION=''${1:-}
        ALIAS=''${2:-}

        show_usage() {
          echo "Usage: crypt-keeper [open|close] [alias]"
          exit 1
        }

        if [[ -z "$ACTION" || -z "$ALIAS" ]]; then show_usage; fi
        if [[ "$ACTION" != "open" && "$ACTION" != "close" ]]; then show_usage; fi

        # Hardcoded array derived safely from the Nix DSL configurations
        case "$ALIAS" in
          ${concatMapStringsSep "\n" (d: let
            # Enforce the baseline options string, then cleanly append extras if they exist
            extraStr = concatStringsSep "," d.extraMountOptions;
            finalOpts = "compress=zstd,nodev,nosuid" + (if extraStr == "" then "" else "," + extraStr);
          in ''
            "${d.alias}")
              UUID="${d.uuid}"
              MOUNT="${d.mountPoint}"
              OPTS="${finalOpts}"
              ;;
          '') cfg.drives}
          *)
            echo "Error: Unknown alias '$ALIAS'."
            exit 1
            ;;
        esac

        case "$ACTION" in
          open)
            sudo -v

            echo "Decrypting LUKS container for $ALIAS..."
            sudo cryptsetup open "/dev/disk/by-uuid/$UUID" "crypt$ALIAS"

            echo "Creating target path if missing..."
            sudo mkdir -p "$MOUNT"

            echo "Mounting file system with calculated parameters ($OPTS)..."
            sudo mount -o "$OPTS" "/dev/mapper/crypt$ALIAS" "$MOUNT"
            echo "✅ Successfully decrypted and mounted to $MOUNT"
            ;;

          close)
            sudo -v

            echo "Safely unmounting $MOUNT..."
            sudo umount "$MOUNT"

            echo "Purging keys from RAM and locking LUKS container..."
            sudo cryptsetup close "crypt$ALIAS"
            echo "🔒 Successfully isolated and locked $ALIAS."
            ;;
        esac
      '')
    ];
  };
}
