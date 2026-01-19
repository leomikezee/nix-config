# Session: niri compositor with DankMaterialShell
{pkgs, ...}: {
  imports = [./default.nix];

  environment.systemPackages = with pkgs; [];

  # services.displayManager.dms-greeter = {
  #   enable = true;
  #   compositor.name = "niri";
  #   configHome = "/home/${vars.username}";
  #   logs = {
  #     save = true;
  #     path = "/tmp/dms-greeter.log";
  #   };
  # };

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

  programs.dms-shell.enable = true;

  programs.niri.enable = true;

  home-manager.sharedModules = [../home/graphical/niri.nix];
}
