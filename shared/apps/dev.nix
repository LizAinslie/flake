{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.android_sdk.accept_license = true;

  services.postgresql = {
    enable = true;

    authentication = pkgs.lib.mkOverride 10 ''
        #type database DBuser origin-address auth-method
        local all      all     trust
        host all all samehost scram-sha-256
    '';

    ensureDatabases = [ "orbit" "kalendee" ];

    ensureUsers = [
      {
        name = "orbit";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          password = "SCRAM-SHA-256$4096:qxAaO71sJ5OF2zcnhBJdhA==$+da8a7cdPNtNH65ow/A7S+w4jn0TF7liHJUgKDN3Vls=:QA1Uwl5O3gZaoQHOH6Jh/fI6Sg0O5nWkuIkbkzKmBAg=";
        };
      }
      {
        name = "kalendee";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
          password = "SCRAM-SHA-256$4096:zbwMUpBA8KUBlfmEi72ilg==$3/rZQVaZMjUoJCFYbwk4jbpMOKhPbMlxOIM4hahW5vM=:HhQwvBf6RcUCLy7YnVQm/bJRRXEjtCS5aOcjJ06sdB0=";
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    jetbrains.idea
    gradle
    android-studio-full
    android-tools
    bun
    httpie-desktop
    yaak
    bruno
    pnpm
    nodejs
    litellm
  ];
}
