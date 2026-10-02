{ config, lib, pkgs, ... }:

let
  s = config.mey.profile.apps.studio;

  # Free Resolve on Linux ships without H.264/H.265/AAC. This is the import path.
  resolveH264 = pkgs.writeShellScriptBin "resolve-h264" ''
    set -eu
    if [ $# -lt 1 ]; then
      echo "usage: resolve-h264 input.mp4 [output.mov]" >&2
      exit 1
    fi
    in="$1"
    out="''${2:-''${in%.*}.mov}"
    exec ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$in" \
      -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p \
      -c:a pcm_s16le \
      "$out"
  '';
in
{
  config = lib.mkIf s.enable {
    programs.obs-studio = lib.mkIf s.obs {
      enable = true;
      enableVirtualCamera = true;
    };

    environment.systemPackages =
      lib.optional s.kdenlive pkgs.kdePackages.kdenlive
      ++ lib.optionals s.resolve [
        pkgs.davinci-resolve
        pkgs.ffmpeg
        resolveH264
      ];
  };
}
