{
  description = "Meyower Flakey :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grok-bot = {
      url = "github:jordangarrison/grok-bot-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # aethermesh = {
    #   url = "git+ssh://github.com/PaulWilkerson/AetherMesh.git";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, catppuccin, home-manager, sops-nix, vicinae, ... }@inputs: {
    nixosConfigurations = {
      meyower = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # passes inputs into configuration.nix
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/meyower/configuration.nix
          sops-nix.nixosModules.sops
          catppuccin.nixosModules.catppuccin

          ({ ... }: {
            home-manager.sharedModules = [ vicinae.homeManagerModules.default ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.mey = import ./home/mey/home.nix;
          }
        ];
      };
    };
  };
}
