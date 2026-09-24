{
  description = "Meyower Flakey :3";

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcaenzgTizIcI3oc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Keep Hyprland on its own nixpkgs lock or the cache misses.
    hyprland.url = "github:hyprwm/Hyprland";

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

    vicinae.url = "github:vicinaehq/vicinae";

    grok-bot = {
      url = "github:jordangarrison/grok-bot-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, catppuccin, home-manager, plasma-manager, sops-nix, vicinae, ... }@inputs:
    let
      mkHost = { hostPath, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            hostPath
            sops-nix.nixosModules.sops
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [
                vicinae.homeManagerModules.default
                plasma-manager.homeModules.plasma-manager
              ];
              home-manager.users.mey = import ./home/mey/home.nix;
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        meyower = mkHost {
          hostPath = ./hosts/meyower/configuration.nix;
        };

        toshinya = mkHost {
          hostPath = ./hosts/toshinya/configuration.nix;
        };
      };
    };
}
