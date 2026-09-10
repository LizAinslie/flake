{ config, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # shell
  programs.fish.enable = true;
  programs.fish.shellAbbrs = {
    # system flake management shortcuts
    nrs = "sudo nixos-rebuild switch --flake /etc/nixos#meyower";
    nfu = "nix flake update /etc/nixos";
    nadd = "git -C /etc/nixos add .";

    # qol shortcuts
    ll = "ls -l";
    la = "ls -la";
  };

  programs.command-not-found.enable = true;

  # boot
  boot.loader = {
    systemd-boot.enable = false;

    grub = {
      enable = true;
      device = "nodev"; # required for EFI
      efiSupport = true;
      enableCryptodisk = true;
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking
  networking.networkmanager.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # time
  time.timeZone = "America/Chicago";

  # i18n
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

  # x11
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # document printing with CUPS
  services.printing.enable = true;

  # pipewire
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

  # gpg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # greeter
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # packages
  environment.systemPackages = with pkgs; [
    fastfetch
    wget
    git
    fish
    libimobiledevice
    ifuse
  ];
}
