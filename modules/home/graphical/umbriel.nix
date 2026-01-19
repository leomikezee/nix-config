# Home config for the Umbriel session. Registered by modules/graphical/umbriel.nix.
_: {
  home.file.".config/umbriel/config.toml".source = ../../../dotfiles/umbriel/config.toml;
}
