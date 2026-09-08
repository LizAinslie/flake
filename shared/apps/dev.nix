{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = with pkgs; [
    jetbrains.idea
    gradle
    android-studio-full
    android-tools
    bun
  ];
}
