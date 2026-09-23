{ config, pkgs, inputs, lib, osConfig, ... }:

let
  profile = osConfig.mey.profile;
  wantHypr =
    profile.desktop == "hypr"
    || profile.desktop == "plasma+hypr"
    || builtins.elem "hypr" profile.sessions;
  wantI3Eww = builtins.elem "i3-eww" profile.sessions;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ../../shared/storage.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "mauve";
  };

  programs.kitty.enable = true;

  programs.eww = lib.mkIf wantI3Eww {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "ryuma" = {
        AddKeysToAgent = "yes";
        Port = 2222;
        HostName = "192.168.68.56";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
  };
  services.gpg-agent.enable = true;
  home.activation = {
    fixGpgPermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "${config.home.homeDirectory}/.gnupg" ]; then
        $DRY_RUN_CMD chmod 700 "${config.home.homeDirectory}/.gnupg"
      fi
    '';
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Elizabeth Hazel Ainslie";
        email = "mey@lizainslie.dev";
      };

      init.defaultBranch = "main";
    };

    signing = {
      key = "AF67306C821877B8";
      signByDefault = true;
    };
  };

  xdg.dataFile."konsole/CatppuccinMochaMauve.colorscheme".text = ''
    [General]
    Description=Catppuccin Mocha Mauve
    Opacity=1
    Wallpaper=

    [Background]
    Color=30,30,46

    [BackgroundIntense]
    Color=24,24,37

    [Color0]
    Color=69,71,90

    [Color0Intense]
    Color=90,93,119

    [Color1]
    Color=243,139,168

    [Color1Intense]
    Color=243,139,168

    [Color2]
    Color=166,227,161

    [Color2Intense]
    Color=166,227,161

    [Color3]
    Color=249,226,175

    [Color3Intense]
    Color=249,226,175

    [Color4]
    Color=137,180,250

    [Color4Intense]
    Color=137,180,250

    [Color5]
    Color=245,194,231

    [Color5Intense]
    Color=245,194,231

    [Color6]
    Color=148,226,213

    [Color6Intense]
    Color=148,226,213

    [Color7]
    Color=166,173,200

    [Color7Intense]
    Color=180,190,254

    [Foreground]
    Color=205,214,244

    [ForegroundIntense]
    Color=205,214,244
  '';

  wayland.windowManager.hyprland.enable = wantHypr;

  home.username = "mey";
  home.homeDirectory = "/home/mey";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
