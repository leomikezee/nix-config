# Home config for the niri session. Registered by modules/graphical/niri.nix.
_: {
  home.file.".config/niri/config.kdl".source = ../../../dotfiles/niri/config.kdl;
}
