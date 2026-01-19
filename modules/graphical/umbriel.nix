# Session: umbriel compositor with noctalia
{pkgs, ...}: {
  imports = [./default.nix];

  security.pam.services.greetd.enableGnomeKeyring = true;

  services.gnome = {
    gcr-ssh-agent.enable = true;
    gnome-keyring.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd start-umbriel";
        user = "greeter";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true;
  };

  programs.umbriel.enable = true;

  home-manager.sharedModules = [../home/graphical/umbriel.nix];
}
