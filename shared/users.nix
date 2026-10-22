{ config, pkgs, inputs, ... }:

{
  users.users."mey" = {
    isNormalUser = true;
    description = "Elizabeth Hazel Ainslie";
    extraGroups = [ "networkmanager" "wheel" "kvm" "bluetooth" ];
    packages = with pkgs; [
    ];
    shell = pkgs.fish;
  };
}
