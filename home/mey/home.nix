{ config, pkgs, inputs, lib, osConfig, ... }:

let
  profile = osConfig.mey.profile;
  onMeyower = osConfig.networking.hostName == "meyower";
  wantHypr =
    onMeyower
    && (
      profile.desktop == "hypr"
      || profile.desktop == "plasma+hypr"
      || builtins.elem "hypr" profile.sessions
    );
  wantPlasma =
    profile.desktop == "plasma"
    || profile.desktop == "plasma+hypr"
    || builtins.elem "plasma" profile.sessions;
  wantI3Eww = builtins.elem "i3-eww" profile.sessions;
  wantVicinae = wantI3Eww || wantHypr || wantPlasma;
  mod = "Mod4";
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ../../shared/storage.nix
    ./look.nix
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

  programs.vicinae = lib.mkIf wantVicinae {
    enable = true;
    systemd.enable = true;
    systemd.autoStart = true;
    systemd.target = if wantI3Eww then "default.target" else "graphical-session.target";
    settings = {
      launcher_window.layer_shell.enabled = wantHypr || wantPlasma;
      global_shortcuts.toggle = "super+space";
    };
  };

  programs.plasma = lib.mkIf wantPlasma {
    enable = true;
    hotkeys.commands."vicinae" = {
      name = "Vicinae";
      key = "Meta+Space";
      command = "vicinae toggle";
    };
    shortcuts."services/plasma-manager-commands.desktop".vicinae = "Meta+Space";
  };

  wayland.windowManager.hyprland = lib.mkIf wantHypr {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    extraConfig = ''
      hl.bind("SUPER + SPACE", function()
        hl.exec_cmd("vicinae toggle")
      end)
    '';
  };

  xsession.windowManager.i3 = lib.mkIf wantI3Eww {
    enable = true;
    config = {
      modifier = mod;
      fonts = {
        names = [ "monospace" ];
        size = 8.0;
      };
      terminal = "kitty";
      menu = "vicinae toggle";
      window.titlebar = true;
      floating.titlebar = true;

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec kitty";
        "${mod}+space" = "exec --no-startup-id vicinae toggle";
        "${mod}+d" = "exec --no-startup-id ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+e" =
          "exec i3-nagbar -t warning -m 'exit i3?' -B 'Yes' 'i3-msg exit'";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+a" = "focus parent";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";
        "${mod}+r" = "mode resize";
      };

      modes.resize = {
        "h" = "resize shrink width 10 px or 10 ppt";
        "j" = "resize grow height 10 px or 10 ppt";
        "k" = "resize shrink height 10 px or 10 ppt";
        "l" = "resize grow width 10 px or 10 ppt";
        "Left" = "resize shrink width 10 px or 10 ppt";
        "Down" = "resize grow height 10 px or 10 ppt";
        "Up" = "resize shrink height 10 px or 10 ppt";
        "Right" = "resize grow width 10 px or 10 ppt";
        "Return" = "mode default";
        "Escape" = "mode default";
        "${mod}+r" = "mode default";
      };

      bars = [{
        statusCommand = "${pkgs.i3status}/bin/i3status";
        position = "bottom";
      }];
    };
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

  home.username = "mey";
  home.homeDirectory = "/home/mey";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
