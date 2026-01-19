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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };
  };
}
