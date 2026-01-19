{
  config,
  pkgs,
  vars,
  ...
}: {
  boot.kernelModules = ["ntsync"];

  environment.systemPackages = with pkgs; [
    protonplus
  ];

  environment.sessionVariables = {
    # overwatch shader compilation fix
    __GL_SHADER_DISK_CACHE = 1;
    __GL_SHADER_DISK_CACHE_PATH = "/home/${vars.username}/.cache/games/overwatch";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = 1;
    __GL_SHADER_DISK_CACHE_SIZE = 12884901888;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };
    gamescopeSession.enable = true;
  };

  programs.gamescope.enable = true;

  programs.gamemode.enable = true;
}
