# Home config for the niri session. Registered by modules/graphical/niri.nix.
{pkgs, ...}: {
  home.packages = [pkgs.playerctl];

  home.file.".config/niri/config.kdl".source = ../../../dotfiles/niri/config.kdl;
}
