# Home config for the Umbriel session. Registered by modules/graphical/umbriel.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    glib # needed by the noctalia KDE Connect plugin
    playerctl
  ];

  home.file.".config/umbriel/config.toml".source = ../../../dotfiles/umbriel/config.toml;
}
