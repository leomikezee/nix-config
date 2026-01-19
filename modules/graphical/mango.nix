# Session: Mango Wayland compositor with Mangobar and fuzzel
{
  config,
  pkgs,
  ...
}: {
  imports = [./default.nix];

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    swaylock = {};
  };

  services.gnome = {
    gcr-ssh-agent.enable = true;
    gnome-keyring.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd mango";
        user = "greeter";
      };
    };
  };

  programs.mango.enable = true;

  home-manager.sharedModules = [../home/graphical/mango.nix];
}
