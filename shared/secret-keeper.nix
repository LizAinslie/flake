# secret-keeper: encrypt -> track -> apply -> back up sops secrets.
# Home-manager module, sibling of crypt-keeper (imported from shared/storage.nix).
#
#   secret-keeper set <name> <key>   prompt for a value (hidden), write it into secrets/<name>.yaml
#   secret-keeper edit <name>        open secrets/<name>.yaml decrypted in $EDITOR (sops)
#   secret-keeper init               encrypt any plaintext secrets/*.yaml in place
#   secret-keeper backup             bundle + passphrase-encrypt, write to the drive (or queue)
#   secret-keeper sync               flush queued bundles to the drive
#   secret-keeper status             drive present? queued bundles? unencrypted files?
#   flags: --no-apply (skip nixos-rebuild), --no-backup
{ config, lib, pkgs, ... }:

let
  cfg = config.services.secret-keeper;

  app = pkgs.writeShellApplication {
    name = "secret-keeper";
    runtimeInputs = with pkgs; [ sops age jq gnutar gzip coreutils util-linux udisks git gnugrep findutils ];
    text = ''
      REPO=${lib.escapeShellArg cfg.repo}
      DRIVE_UUID=${lib.escapeShellArg (if cfg.drive.uuid == null then "" else cfg.drive.uuid)}
      DRIVE_DIR=${lib.escapeShellArg cfg.drive.dir}
      ON_MISSING=${lib.escapeShellArg cfg.onMissing}
      QUEUE="''${XDG_STATE_HOME:-$HOME/.local/state}/secret-keeper/pending"
      PATHS=(${lib.concatMapStringsSep " " lib.escapeShellArg cfg.paths})
      SECRETS="$REPO/secrets"

      apply=1; backup=1; args=()
      for a in "$@"; do
        case "$a" in
          --no-apply) apply=0 ;;
          --no-backup) backup=0 ;;
          *) args+=("$a") ;;
        esac
      done
      set -- "''${args[@]}"

      die() { echo "secret-keeper: $*" >&2; exit 1; }
      is_encrypted() { grep -q '^sops:' "$1"; }
      can_decrypt() { sops decrypt "$1" >/dev/null 2>&1; }
      # Post-quantum only: any classical age1 recipient caps the file at X25519 strength.
      classical() { grep -oE 'age1[02-9ac-hj-np-z]{58}\b' "$1" | grep -v '^age1pq1' || true; }
      guard_pq() {
        [[ -z $(classical "$REPO/.sops.yaml") ]] || die ".sops.yaml has a non-PQ age recipient; use age-keygen -pq"
      }
      fileof() { [[ "$1" =~ ^[A-Za-z0-9._-]+$ ]] || die "bad name: $1"; echo "$SECRETS/''${1%.yaml}.yaml"; }

      # Only ever force-add files that are verifiably encrypted. secrets/ stays
      # gitignored so `git add .` can never stage a plaintext file by accident.
      track() {
        is_encrypted "$1" || die "refusing to track unencrypted $1"
        can_decrypt "$1" || die "can't decrypt $1 with your key (encrypted to a different/old key?)"
        [[ -z $(classical "$1") ]] || die "$1 is encrypted to a non-PQ recipient; re-encrypt it"
        git -C "$REPO" add -f "$1"
        echo "tracked $(realpath --relative-to="$REPO" "$1") (commit when ready)"
      }

      do_apply() {
        [[ $apply == 1 ]] || return 0
        echo "applying: nixos-rebuild switch --flake $REPO#$(hostname)"
        sudo nixos-rebuild switch --flake "$REPO#$(hostname)"
      }

      # Prints the drive's mountpoint, mounting it via udisks (no sudo) if needed.
      drive_mount() {
        [[ -n $DRIVE_UUID ]] || return 1
        local dev="/dev/disk/by-uuid/$DRIVE_UUID" mnt
        [[ -e $dev ]] || return 1
        mnt=$(findmnt -nro TARGET --source "$dev" | head -n1 || true)
        if [[ -z $mnt ]]; then
          udisksctl mount -b "$dev" >/dev/null || return 1
          mnt=$(findmnt -nro TARGET --source "$dev" | head -n1)
        fi
        [[ -n $mnt ]] || return 1
        mkdir -p "$mnt/$DRIVE_DIR"
        echo "$mnt/$DRIVE_DIR"
      }

      deliver() { # $1 = bundle file; copy + verify on the drive, or queue/fail
        local dest
        if dest=$(drive_mount); then
          cp "$1" "$dest/"
          sync
          cmp -s "$1" "$dest/$(basename "$1")" || die "verify failed on drive copy"
          echo "backed up -> $dest/$(basename "$1")"
          return 0
        fi
        if [[ $ON_MISSING == fail ]]; then
          die "backup drive ''${DRIVE_UUID:-<not configured>} not present"
        fi
        mkdir -p "$QUEUE"
        cp "$1" "$QUEUE/"
        echo "drive not present; queued $(basename "$1") (run: secret-keeper sync)"
      }

      do_backup() {
        [[ $backup == 1 ]] || return 0
        local tmp out list=()
        tmp=$(mktemp -d)
        for p in "''${PATHS[@]}"; do
          [[ -e $p ]] && list+=("$p") || echo "skip (missing): $p"
        done
        while IFS= read -r f; do list+=("$f"); done < <(find "$SECRETS" -maxdepth 1 -name '*.yaml' -type f)
        list+=("$REPO/.sops.yaml")
        out="$tmp/secrets-$(hostname)-$(date +%Y%m%d-%H%M%S).tar.gz.age"
        echo "backup passphrase: this is what you need to restore. empty = age generates one and prints it (save it!)"
        tar -czf - --absolute-names "''${list[@]}" | age -p -o "$out"
        deliver "$out" || { rm -rf "$tmp"; return 1; }
        rm -rf "$tmp"
      }

      cmd=''${1:-status}; shift || true
      case "$cmd" in set|edit|init) guard_pq ;; esac
      case "$cmd" in
        set)
          [[ $# -eq 2 ]] || die "usage: secret-keeper set <name> <key>"
          f=$(fileof "$1"); key=$2
          read -rsp "value for $key: " val; echo
          [[ -n $val ]] || die "empty value"
          if [[ -f $f ]]; then
            is_encrypted "$f" || die "$f is plaintext; run: secret-keeper init"
            printf '%s' "$val" | jq -Rs . | sops set --value-stdin "$f" "[$(jq -n --arg k "$key" '$k')]"
          else
            mkdir -p "$SECRETS"
            jq -n --arg k "$key" --arg v "$val" '{($k): $v}' \
              | sops encrypt --filename-override "$f" --input-type json --output-type yaml /dev/stdin > "$f.tmp"
            mv "$f.tmp" "$f"
          fi
          unset val
          track "$f"; do_backup; do_apply ;;
        edit)
          [[ $# -eq 1 ]] || die "usage: secret-keeper edit <name>"
          f=$(fileof "$1")
          [[ ! -f $f ]] || is_encrypted "$f" || die "$f is plaintext; run: secret-keeper init"
          sops edit "$f"
          track "$f"; do_backup; do_apply ;;
        init)
          for f in "$SECRETS"/*.yaml; do
            [[ -f $f ]] || continue
            if is_encrypted "$f"; then echo "ok: $f"; else
              sops encrypt -i "$f"; echo "encrypted: $f"
            fi
            track "$f"
          done
          do_backup; do_apply ;;
        backup) do_backup ;;
        sync)
          shopt -s nullglob; q=("$QUEUE"/*.age)
          [[ ''${#q[@]} -gt 0 ]] || { echo "queue empty"; exit 0; }
          dest=$(drive_mount) || die "backup drive not present"
          for b in "''${q[@]}"; do
            cp "$b" "$dest/" && sync && cmp -s "$b" "$dest/$(basename "$b")" \
              && rm "$b" && echo "synced $(basename "$b")"
          done ;;
        status)
          if d=$(drive_mount 2>/dev/null); then echo "drive: present at $d"
          else echo "drive: ''${DRIVE_UUID:-not configured} (not present)"; fi
          shopt -s nullglob; q=("$QUEUE"/*.age); echo "queued bundles: ''${#q[@]}"
          for f in "$SECRETS"/*.yaml; do
            [[ -f $f ]] && ! is_encrypted "$f" && echo "PLAINTEXT: $f"
          done; true ;;
        *) die "unknown command: $cmd" ;;
      esac
    '';
  };
in
{
  options.services.secret-keeper = {
    enable = lib.mkEnableOption "sops secret helper with drive backups";
    repo = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.home.homeDirectory}/.config/sops/age/keys.txt" ];
      description = "Extra files bundled into every backup, besides secrets/*.yaml and .sops.yaml.";
    };
    drive = {
      uuid = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Filesystem UUID of the backup drive this tool owns (lsblk -f). null = no drive yet.";
      };
      dir = lib.mkOption {
        type = lib.types.str;
        default = "secret-keeper";
      };
    };
    onMissing = lib.mkOption {
      type = lib.types.enum [ "queue" "fail" ];
      default = "queue";
      description = "When the drive is absent: queue the encrypted bundle locally for `sync`, or fail.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ app ];
  };
}
