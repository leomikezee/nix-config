# Session: Plasma Bigscreen, a TV interface driven by remote/gamepad.
{
  pkgs,
  vars,
  ...
}: {
  imports = [./default.nix];

  environment.systemPackages = [pkgs.kdePackages.plasma-bigscreen];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    ark
    aurorae
    baloo-widgets
    dolphin
    dolphin-plugins
    elisa
    ffmpegthumbs
    gwenview
    kate
    khelpcenter
    konsole
    krdp
    ktexteditor
    okular
    plasma-browser-integration
    plasma-workspace-wallpapers
    spectacle
  ];

  xdg.portal.configPackages = [pkgs.kdePackages.plasma-bigscreen];

  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    sddm.enable = true;
    sessionPackages = [pkgs.kdePackages.plasma-bigscreen];
    defaultSession = "plasma-bigscreen-wayland";
    autoLogin = {
      enable = true;
      user = vars.username;
    };
  };
}
