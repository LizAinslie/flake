{
  description = "Meyower Flakey :3";

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # No `follows` on purpose: hyprland and vicinae publish cachix builds made
    # against their own pinned nixpkgs. Following ours = cache misses = local
    # source builds. The extra nixpkgs copies are the price of the cache.
    hyprland.url = "github:hyprwm/Hyprland";
    vicinae.url = "github:vicinaehq/vicinae";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grok-bot = {
      url = "github:jordangarrison/grok-bot-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fluxer = {
      url = "github:Hy4ri/fluxer-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    epic-games-launcher = {
      url = "github:kjetteren/epic-games-launcher-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    t3code = {
      url = "github:LizAinslie/t3code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = lib.genAttrs systems;

      # Host discovery: every hosts/<name>/ becomes a config. A folder with
      # configuration.nix is a NixOS host, one with darwin.nix is a nix-darwin
      # host. New host = new folder, no flake.nix edit.
      hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts);
      hostsWith = file: lib.filterAttrs (name: _: builtins.pathExists (./hosts + "/${name}/${file}")) hostDirs;

      mkNixos = name: _:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${name}/configuration.nix
            inputs.sops-nix.nixosModules.sops
            inputs.catppuccin.nixosModules.catppuccin
            ./shared/home.nix
          ];
        };

      mkDarwin = name: _:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${name}/darwin.nix ];
        };

      # Every host's full system build is a check, grouped by its platform,
      # so `nix flake check` catches one host breaking while you switch another.
      hostChecks = configs: toplevel:
        lib.foldlAttrs (acc: name: cfg:
          lib.recursiveUpdate acc {
            ${cfg.pkgs.stdenv.hostPlatform.system}.${name} = toplevel cfg;
          }) { } configs;
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixos (hostsWith "configuration.nix");
      darwinConfigurations = lib.mapAttrs mkDarwin (hostsWith "darwin.nix");

      checks = lib.recursiveUpdate
        (hostChecks self.nixosConfigurations (c: c.config.system.build.toplevel))
        (hostChecks self.darwinConfigurations (c: c.system));

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ nixd nixfmt sops ];
          };
        });
    };
}
