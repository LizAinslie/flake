{ config, lib, ... }:

let
  tools = config.mey.profile.apps.tools;
  secretsFile = ../../secrets/ksnip.yaml;
  hasSecret = builtins.pathExists secretsFile;
in
{
  options.mey.profile.apps.tools.ksnipUpload = {
    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "nocf.lets-go-on-a.date:64413/upload/png";
      description = "Upload endpoint. Scheme is optional; curl treats host:port/path as http.";
    };
    header = lib.mkOption {
      type = lib.types.str;
      default = "x-rph-auth";
      description = "Auth header name sent to the upload endpoint.";
    };
    contentType = lib.mkOption {
      type = lib.types.str;
      default = "data/raw";
    };
    providersFile = lib.mkOption {
      type = lib.types.str;
      default = "/home/mey/screenshot-providers.txt";
      description = "One public base URL per line. A line is chosen at upload time. Not in the store.";
    };
  };

  # Secret file is optional until you encrypt secrets/ksnip.yaml.
  # Key is upload_token. Age key: /home/mey/.config/sops/age/keys.txt
  config = lib.mkIf (tools.enable && tools.ksnip && hasSecret) {
    sops.age.keyFile = lib.mkDefault "/home/mey/.config/sops/age/keys.txt";
    sops.secrets.ksnip-upload-token = {
      sopsFile = secretsFile;
      key = "upload_token";
      owner = "mey";
      mode = "0400";
    };
  };
}
