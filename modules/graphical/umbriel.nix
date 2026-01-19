# Session: umbriel compositor with noctalia
{pkgs, ...}: {
  imports = [./default.nix];

  # needed by noctalia kde connect plugin
  environment.systemPackages = with pkgs; [glib];

  security.pam.services.greetd.enableGnomeKeyring = true;

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

  services.gnome = {
    gcr-ssh-agent.enable = true;
    gnome-keyring.enable = true;
  };

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true;
  };

  programs.umbriel.enable = true;

  home-manager.sharedModules = [../home/graphical/umbriel.nix];
}
