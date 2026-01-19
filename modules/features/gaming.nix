{pkgs, ...}: {
  boot.kernelModules = ["ntsync"];

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      # Steam uses XIM; desktop launchers may not inherit the shell's IM settings.
      extraEnv.XMODIFIERS = "@im=fcitx";
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.joycond.enable = true;

  home-manager.sharedModules = [../home/features/gaming.nix];
}
