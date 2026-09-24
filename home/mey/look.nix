{ config, pkgs, lib, osConfig, ... }:

let
  wantI3Eww = builtins.elem "i3-eww" osConfig.mey.profile.sessions;
  wallDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  currentLink = "${config.home.homeDirectory}/.local/share/wallpaper/current";

  applyWallpaper = pkgs.writeShellScript "apply-wallpaper" ''
    set -eu
    img="$1"
    mkdir -p "${config.home.homeDirectory}/.local/share/wallpaper"
    ln -sfn "$img" "${currentLink}"
    if [ -n "$${WAYLAND_DISPLAY:-}" ]; then
      if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
        plasma-apply-wallpaperimage "$img"
      elif command -v swww >/dev/null 2>&1; then
        swww img "$img"
      fi
    else
      ${pkgs.feh}/bin/feh --no-fehbg --bg-fill "$img"
    fi
  '';

  scriptWallpaperRandom = pkgs.writeShellScript "vicinae-wallpaper-random" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Wallpaper: random
    # @vicinae.mode silent
    # @vicinae.icon image
    set -eu
    dir="${wallDir}"
    mkdir -p "$dir"
    img=$(${pkgs.findutils}/bin/find "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | ${pkgs.coreutils}/bin/shuf -n 1 || true)
    if [ -z "$${img:-}" ]; then
      echo "Drop images in $dir" >&2
      exit 1
    fi
    ${applyWallpaper} "$img"
  '';

  scriptWallpaperPick = pkgs.writeShellScript "vicinae-wallpaper-pick" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Wallpaper: pick
    # @vicinae.mode silent
    # @vicinae.icon image
    set -eu
    dir="${wallDir}"
    mkdir -p "$dir"
    img=$(${pkgs.findutils}/bin/find "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -printf '%f\n' \
      | ${pkgs.coreutils}/bin/sort \
      | vicinae dmenu --placeholder "wallpaper")
    [ -n "$${img:-}" ] || exit 0
    ${applyWallpaper} "$dir/$img"
  '';

  mkTheme = name: flavor: pkgs.writeShellScript "vicinae-theme-${flavor}" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Theme: ${name}
    # @vicinae.mode silent
    # @vicinae.icon paintbrush
    set -eu
    cfg="${config.home.homeDirectory}/.config/vicinae/settings.json"
    mkdir -p "$(dirname "$cfg")"
    if [ -f "$cfg" ]; then
      ${pkgs.jq}/bin/jq --arg t "${flavor}" '.theme.name = $t' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    else
      printf '%s\n' "{\"theme\":{\"name\":\"${flavor}\"}}" > "$cfg"
    fi
    systemctl --user try-reload-or-restart vicinae.service >/dev/null 2>&1 || true
  '';

  themes = {
    mocha = mkTheme "Catppuccin Mocha" "catppuccin-mocha";
    macchiato = mkTheme "Catppuccin Macchiato" "catppuccin-macchiato";
    frappe = mkTheme "Catppuccin Frappe" "catppuccin-frappe";
    latte = mkTheme "Catppuccin Latte" "catppuccin-latte";
  };
in
{
  home.packages = [ pkgs.jq ] ++ lib.optional wantI3Eww pkgs.feh;

  home.activation.vicinaeLookScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dest="${config.home.homeDirectory}/.local/share/vicinae/scripts"
    $DRY_RUN_CMD mkdir -p "$dest" "${wallDir}" \
      "${config.home.homeDirectory}/.local/share/wallpaper"
    $DRY_RUN_CMD cp -f ${scriptWallpaperRandom} "$dest/wallpaper-random"
    $DRY_RUN_CMD cp -f ${scriptWallpaperPick} "$dest/wallpaper-pick"
    $DRY_RUN_CMD cp -f ${themes.mocha} "$dest/theme-mocha"
    $DRY_RUN_CMD cp -f ${themes.macchiato} "$dest/theme-macchiato"
    $DRY_RUN_CMD cp -f ${themes.frappe} "$dest/theme-frappe"
    $DRY_RUN_CMD cp -f ${themes.latte} "$dest/theme-latte"
    $DRY_RUN_CMD chmod 755 "$dest"/*
  '';

  xsession.windowManager.i3.config.startup = lib.mkIf wantI3Eww [
    {
      command = "[ -e ${currentLink} ] && ${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${currentLink}";
      notification = false;
    }
  ];

  programs.vicinae.themes = {
    catppuccin-mocha = {
      meta = {
        version = 1;
        name = "Catppuccin Mocha";
        description = "Catppuccin Mocha";
        variant = "dark";
        inherits = "vicinae-dark";
      };
      colors.core = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        accent = "#cba6f7";
      };
    };
    catppuccin-macchiato = {
      meta = {
        version = 1;
        name = "Catppuccin Macchiato";
        description = "Catppuccin Macchiato";
        variant = "dark";
        inherits = "vicinae-dark";
      };
      colors.core = {
        background = "#24273a";
        foreground = "#cad3f5";
        accent = "#c6a0f6";
      };
    };
    catppuccin-frappe = {
      meta = {
        version = 1;
        name = "Catppuccin Frappe";
        description = "Catppuccin Frappe";
        variant = "dark";
        inherits = "vicinae-dark";
      };
      colors.core = {
        background = "#303446";
        foreground = "#c6d0f5";
        accent = "#ca9ee6";
      };
    };
    catppuccin-latte = {
      meta = {
        version = 1;
        name = "Catppuccin Latte";
        description = "Catppuccin Latte";
        variant = "light";
        inherits = "vicinae-light";
      };
      colors.core = {
        background = "#eff1f5";
        foreground = "#4c4f69";
        accent = "#8839ef";
      };
    };
  };
}
