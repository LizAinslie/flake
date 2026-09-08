{ config, pkgs, inputs, ... }:

{
  users.users."mey" = {
    isNormalUser = true;
    description = "Elizabeth Hazel Ainslie";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
    shell = pkgs.fish;
  };
}
