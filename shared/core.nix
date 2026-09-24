{ config, pkgs, inputs, lib, ... }:

let
  p = config.mey.profile;
in
{
  imports = [ ./profile.nix ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };

  programs.fish.enable = true;
  programs.fish.shellAbbrs = {
    nrs = "sudo nixos-rebuild switch --flake /etc/nixos#${config.networking.hostName}";
    nfu = "nix flake update /etc/nixos";
    nadd = "git -C /etc/nixos add .";
    ll = "ls -l";
    la = "ls -la";
  };

  programs.command-not-found.enable = true;

  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = p.grubDevice;
      efiSupport = p.firmware == "efi";
      enableCryptodisk = p.firmware == "efi";
    };
    efi = {
      canTouchEfiVariables = p.firmware == "efi";
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelPackages =
    if p.kernel == "latest"
    then pkgs.linuxPackages_latest
    else pkgs.linuxPackages;

  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  environment.sessionVariables.LD_LIBRARY_PATH = [ "${pkgs.libglvnd}/lib" ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.displayManager.sddm = {
    enable = p.displayManager == "sddm";
    wayland.enable = p.displayManager == "sddm";
  };

  nixpkgs.config.allowUnfree = true;

  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    wget
    git
    fish
    libimobiledevice
    ifuse
    kitty
  ];
}
