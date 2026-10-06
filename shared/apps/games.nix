{ config, lib, pkgs, ... }:

let
  g = config.mey.profile.apps.games;

  # Last GE-Proton 10. unstable's proton-ge-bin is already GE-Proton 11,
  # and its tarball name no longer matches the 10.x release assets.
  proton-ge-10 = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "proton-ge-bin";
    version = "GE-Proton10-34";
    steamDisplayName = "GE-Proton10";

    src = pkgs.fetchzip {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-lzPsYYcrp5NoT3B0WFj3o10Z7tXx7xva1wEP3edeuqM=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    outputs = [
      "out"
      "steamcompattool"
    ];

    installPhase = ''
      runHook preInstall
      echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out
      mkdir $steamcompattool
      ln -s $src/* $steamcompattool
      rm $steamcompattool/compatibilitytool.vdf
      cp $src/compatibilitytool.vdf $steamcompattool
      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "${finalAttrs.version}" "${finalAttrs.steamDisplayName}"
    '';

    meta.platforms = [ "x86_64-linux" ];
  });
in
{
  config = lib.mkIf g.enable {
    environment.systemPackages =
      lib.optional g.steam pkgs.steam
      ++ lib.optional g.protonup pkgs.protonup-qt
      ++ lib.optional g.prism pkgs.prismlauncher;

    programs.steam = lib.mkIf g.steam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = lib.optional g.protonGe proton-ge-10;
    };

    programs.gamemode.enable = g.gamemode;

  };
}
