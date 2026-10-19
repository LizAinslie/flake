# MacBook Air M1 (8 GB). nix-darwin + nixpkgs only, no NixOS modules.
# Minimal on purpose: yabai + skhd tiling, waiting for the clean reinstall.
# Bootstrap after installing Nix:
#   nix run nix-darwin -- switch --flake /etc/nixos#macbook
{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "macbook";
  system.primaryUser = "mey";
  users.users.mey.home = "/Users/mey";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.yabai = {
    enable = true;
    # Scripting addition needs SIP partially disabled; leave off until decided.
    enableScriptingAddition = false;
    config = {
      layout = "bsp";
      window_placement = "second_child";
      window_gap = 8;
      top_padding = 8;
      bottom_padding = 8;
      left_padding = 8;
      right_padding = 8;
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
    };
  };

  # i3-ish bindings (alt as mod; cmd stays macOS's).
  services.skhd = {
    enable = true;
    skhdConfig = ''
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east
      alt - f : yabai -m window --toggle zoom-fullscreen
      shift + alt - space : yabai -m window --toggle float
      alt - return : open -na kitty
    '';
  };

  environment.systemPackages = with pkgs; [ kitty git ];

  system.stateVersion = 6;
}
