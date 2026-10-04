{ config, lib, pkgs, ... }:

let
  cfg = config.mey.graphics.gameDevice;

  libraries = {
    nvidia = "libGLX_nvidia.so.0";
    radv = "libvulkan_radeon.so";
  };

  icd = { bits, library }:
    pkgs.writeText "game-device-${bits}.json" (builtins.toJSON {
      file_format_version = "1.0.1";
      ICD = {
        library_path = "/run/opengl-driver${lib.optionalString (bits == "32") "-32"}/lib/${library}";
        api_version = "1.4.303";
      };
    });

  library = libraries.${cfg.driver};
  icd64 = icd { bits = "64"; inherit library; };
  icd32 = icd { bits = "32"; inherit library; };
  driverFiles = "${icd64}:${icd32}";

  gameEnv = {
    VK_DRIVER_FILES = driverFiles;
    DXVK_FILTER_DEVICE_NAME = cfg.name;
    MESA_VK_DEVICE_SELECT = "${cfg.vendor}:${cfg.device}!";
  };

  vulkan-game = pkgs.writeShellScriptBin "vulkan-game" ''
    export VK_DRIVER_FILES=${lib.escapeShellArg driverFiles}
    export DXVK_FILTER_DEVICE_NAME=${lib.escapeShellArg cfg.name}
    export MESA_VK_DEVICE_SELECT=${lib.escapeShellArg "${cfg.vendor}:${cfg.device}!"}
    exec "$@"
  '';
in
{
  options.mey.graphics.gameDevice = {
    enable = lib.mkEnableOption "pin Vulkan games to one device, leaving the session loader alone";

    name = lib.mkOption {
      type = lib.types.str;
      default = "NVIDIA GeForce RTX 3080";
      description = "Device name passed to DXVK_FILTER_DEVICE_NAME. Must match vulkaninfo deviceName.";
    };

    vendor = lib.mkOption {
      type = lib.types.strMatching "[0-9a-fA-F]{4}";
      default = "10de";
      description = "PCI vendor id, without 0x. 10de is NVIDIA, 1002 is AMD.";
    };

    device = lib.mkOption {
      type = lib.types.strMatching "[0-9a-fA-F]{4}";
      default = "2206";
      description = "PCI device id, without 0x. 2206 is the RTX 3080, 164e is Raphael.";
    };

    driver = lib.mkOption {
      type = lib.types.enum [ "nvidia" "radv" ];
      default = "nvidia";
      description = "Which userspace ICD the generated manifest loads.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ vulkan-game ];

    # Steam's own package is overridden in apps/games.nix so the client and
    # every game it spawns see this, and Plasma/Firefox do not.
    environment.etc."vulkan/icd.d/game-device.json".source = icd64;
    environment.etc."vulkan/icd.d/game-device-32.json".source = icd32;

    programs.steam.package = lib.mkIf config.programs.steam.enable (
      pkgs.steam.override { extraEnv = gameEnv; }
    );
  };
}
