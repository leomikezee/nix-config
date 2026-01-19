{
  config,
  pkgs,
  vars,
  ...
}: {
  boot.kernelModules = ["ntsync"];

  environment.systemPackages = with pkgs; [
    lutris
    protonplus
  ];

  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
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
