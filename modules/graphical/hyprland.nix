# Session: Hyprland compositor with ashell and fuzzel
{pkgs, ...}: {
  imports = [./default.nix];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.hyprland.enable = true;

  home-manager.sharedModules = [../home/graphical/hyprland.nix];
}
