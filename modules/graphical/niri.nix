# Session: niri compositor with Dux Modular Shell
{pkgs, ...}: {
  imports = [./default.nix];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.dux-shell.enable = true;

  programs.niri.enable = true;

  home-manager.sharedModules = [../home/graphical/niri.nix];
}
