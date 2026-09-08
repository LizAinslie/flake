{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ../shared/storage.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "mauve";
  };

  # ssh
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      AddKeysToAgent = "yes";
    };
  };

  # gpg

  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
  };
  services.gpg-agent = {
    enable = true;
  };
  home.activation = {
    fixGpgPermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "${config.home.homeDirectory}/.gnupg" ]; then
        $DRY_RUN_CMD chmod 700 "${config.home.homeDirectory}/.gnupg"
      fi
    '';
  };

  # git
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Elizabeth Hazel Ainslie";
        email = "mey@lizainslie.dev";
      };
    };

    signing = {
      key = "AF67306C821877B8";
      signByDefault = true;
    };
  };


  # catppuccin for konsole
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

  home.username = "mey";
  home.homeDirectory = "/home/mey";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
