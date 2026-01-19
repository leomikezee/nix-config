# Session: Hyprland compositor with ashell and fuzzel
{
  config,
  pkgs,
  ...
}: {
  imports = [./default.nix];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  home-manager.sharedModules = [../home/graphical/hyprland.nix];
}
