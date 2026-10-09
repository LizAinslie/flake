{ config, lib, pkgs, osConfig, ... }:

let
  tools = osConfig.mey.profile.apps.tools;
  upload = tools.ksnipUpload;
  secretPath =
    if osConfig.sops.secrets ? ksnip-upload-token
    then osConfig.sops.secrets.ksnip-upload-token.path
    else "/run/secrets/ksnip-upload-token";

  uploadScript = pkgs.writeShellScript "ksnip-upload" ''
    set -uo pipefail

    image="''${1:-}"
    providers="${upload.providersFile}"
    secret_file="${secretPath}"
    notify=${pkgs.libnotify}/bin/notify-send

    fail() {
      "$notify" "Image Uploader" "$1" --icon=dialog-error
      exit 1
    }

    [ -n "$image" ] && [ -f "$image" ] || fail "ksnip did not pass an image"
    [ -f "$providers" ] || fail "providers file not found: $providers"
    [ -r "$secret_file" ] || fail "sops secret unreadable: $secret_file"

    provider=$(${pkgs.gnugrep}/bin/grep -v '^[[:space:]]*$' "$providers" | ${pkgs.coreutils}/bin/shuf -n 1 | ${pkgs.coreutils}/bin/tr -d ' \t\r')
    [ -n "$provider" ] || fail "no providers in $providers"

    secret=$(${pkgs.coreutils}/bin/tr -d ' \t\r\n' < "$secret_file")
    name=$(${pkgs.curl}/bin/curl -fsS -X POST --data-binary "@$image" \
      -H "${upload.header}: $secret" \
      -H "content-type: ${upload.contentType}" \
      "${upload.endpoint}" | ${pkgs.jq}/bin/jq -r '.name // empty') || fail "upload request failed"

    [ -n "$name" ] && [ "$name" != "null" ] || fail "upload failed"

    url="''${provider%/}/$name"
    printf '%s\n' "$url"

    if [ -n "''${WAYLAND_DISPLAY:-}" ] && [ -x ${pkgs.wl-clipboard}/bin/wl-copy ]; then
      printf '%s' "$url" | ${pkgs.wl-clipboard}/bin/wl-copy
    elif [ -x ${pkgs.xclip}/bin/xclip ]; then
      printf '%s' "$url" | ${pkgs.xclip}/bin/xclip -selection clipboard
    fi

    "$notify" "Image Uploader" "Uploaded to $(${pkgs.coreutils}/bin/basename "$provider")" --icon=dialog-information
  '';
in
{
  config = lib.mkIf (tools.enable && tools.ksnip) {
    home.packages = [ pkgs.wl-clipboard pkgs.xclip ];

    # ksnip stores UploaderType as an int: Imgur=0, Script=1, Ftp=2.
    # StopOnStdErr key is misspelled upstream (UploadScriptStoOnStdErr).
    xdg.configFile."ksnip/ksnip.conf".text = ''
      [Uploader]
      UploaderType=1

      [UploadScript]
      UploadScriptPath=${uploadScript}
      CopyOutputToClipboard=true
      UploadScriptStoOnStdErr=false
      CopyOutputFilter=
    '';
  };
}
