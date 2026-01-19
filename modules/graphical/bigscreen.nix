# Session: Plasma Bigscreen, a TV interface driven by remote/gamepad.
{
  pkgs,
  vars,
  ...
}: {
  imports = [./default.nix];

  environment.systemPackages = [pkgs.kdePackages.plasma-bigscreen];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    aurorae
    plasma-browser-integration
    plasma-workspace-wallpapers
    konsole
    kwin-x11
    ark
    elisa
    gwenview
    okular
    kate
    ktexteditor
    khelpcenter
    dolphin
    baloo-widgets
    dolphin-plugins
    spectacle
    ffmpegthumbs
    krdp
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
