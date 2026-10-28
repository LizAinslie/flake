# hibi beta + nightly from source, both with the in-app updater off.
# Reuses the upstream nix/package.nix from the nightly input (v0.2.1 has no
# nix/ dir) and swaps src / npm deps / desktop entry per channel.
{ inputs, system }:

let
  # hibi needs electron_44; use hibi's own nixpkgs pin (no follows).
  pkgs = inputs.hibi-nightly.inputs.nixpkgs.legacyPackages.${system};
  inherit (pkgs) lib;
  mimeTypes = [
    "text/plain" "text/markdown" "text/x-mdx" "text/x-tex" "text/x-rst"
    "text/x-asciidoc" "text/org" "text/x-typst" "text/html" "text/x-mediawiki"
    "text/x-r-markdown" "text/x-quarto" "text/x-mdsvex" "text/x-markdoc"
    "text/x-djot" "text/x-textile" "text/x-creole" "text/x-mermaid"
    "text/x-bbcode" "x-scheme-handler/hibi"
  ];
  upstream = pkgs.callPackage "${inputs.hibi-nightly}/nix/package.nix";

  mk = { variant, src, version, npmDepsHash ? null, desktopName, bin }:
    let
      base = upstream { inherit version; };
      icon = "com.ryanaque.hibi.${variant}";
    in
    base.overrideAttrs (old: {
      pname = bin;
      inherit src;
    } // lib.optionalAttrs (npmDepsHash != null) {
      npmDeps = pkgs.fetchNpmDeps {
        inherit src;
        name = "${bin}-${version}-npm-deps";
        hash = npmDepsHash;
      };
    } // {
      # Updater off: loadUpdates() computes state.supported (true only for
      # AppImage/mac/win). Force it false, so startUpdateChecks() and
      # checkForUpdates() bail and the UI shows "unsupported".
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/main/updates.ts --replace-fail \
          '  state.message = state.supported' \
          '  state.supported = false /* nix: updater disabled */
          state.message = state.supported'
      '';

      postInstall = (old.postInstall or "") + ''
        ${lib.optionalString (bin != "hibi") "mv $out/bin/hibi $out/bin/${bin}"}
        mv $out/share/icons/hicolor/512x512/apps/com.ryanaque.hibi.png \
          $out/share/icons/hicolor/512x512/apps/${icon}.png
      '';

      desktopItems = [
        (pkgs.makeDesktopItem {
          name = icon;
          inherit desktopName icon;
          comment = "Desktop editor for local notes and documents (${variant})";
          exec = "${bin} %U";
          categories = [ "Office" ];
          inherit mimeTypes;
          startupWMClass = "hibi";
        })
      ];

      meta = old.meta // { mainProgram = bin; };
    });
in
{
  beta = mk {
    variant = "beta";
    src = inputs.hibi-beta;
    version = "0.2.1";
    npmDepsHash = "sha256-cssQeDx9vMn9WY246ZxKHfQWa+s0QJ75RdRTI5rO4hQ=";
    desktopName = "Hibi (Beta)";
    bin = "hibi";
  };
  nightly = mk {
    variant = "nightly";
    src = inputs.hibi-nightly;
    version = "0.2.2-nightly.20261028.g759dae1";
    desktopName = "Hibi (Nightly)";
    bin = "hibi-nightly";
  };
}
