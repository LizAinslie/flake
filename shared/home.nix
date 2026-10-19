# Home-manager wiring for NixOS hosts. Moved out of flake.nix so the flake
# stays an entrypoint (ekala nix-book ch10: "treat flakes as an entrypoint").
{ inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [
      inputs.vicinae.homeManagerModules.default
      inputs.plasma-manager.homeModules.plasma-manager
    ];
    users.mey = import ../home/mey/home.nix;
  };
}
