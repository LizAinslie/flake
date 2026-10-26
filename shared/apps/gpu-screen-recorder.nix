{ config, lib, pkgs, ... }:

# Always-on 90s replay buffer. F8 (bound in home/mey/home.nix) runs
# gsr-save-replay, which sends SIGUSR1 to save the buffer to ~/Videos/Replays.
let
  tools = config.mey.profile.apps.tools;
  saveReplay = pkgs.writeShellScriptBin "gsr-save-replay" ''
    if ${pkgs.procps}/bin/pkill -SIGUSR1 -f '^gpu-screen-recorder'; then
      ${pkgs.libnotify}/bin/notify-send -a "GPU Screen Recorder" -i media-record "Replay saved" "Last 90s -> ~/Videos/Replays"
    else
      ${pkgs.libnotify}/bin/notify-send -a "GPU Screen Recorder" -i dialog-error "Replay not running" "systemctl --user status gpu-screen-recorder-replay"
    fi
  '';
in
{
  config = lib.mkIf (tools.enable && tools.gpu-screen-recorder) {
    # Module adds the cap_sys_admin wrapper for gsr-kms-server (KMS capture).
    programs.gpu-screen-recorder.enable = true;
    environment.systemPackages = [ saveReplay ];

    systemd.user.services.gpu-screen-recorder-replay = {
      description = "GPU Screen Recorder 90s replay buffer";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      path = [ "/run/wrappers" config.programs.gpu-screen-recorder.package ];
      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Videos/Replays";
        ExecStart = "${config.programs.gpu-screen-recorder.package}/bin/gpu-screen-recorder -w screen -f 60 -r 90 -c mp4 -a default_output -o %h/Videos/Replays";
        # SIGINT = stop without saving in replay mode.
        KillSignal = "SIGINT";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
