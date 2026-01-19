# Home config for the Hyprland session. Registered by modules/graphical/hyprland.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    ashell
    fuzzel
    grim
    hyprshutdown
    hyprsunset
    slurp
    swaybg
  ];

  home.file.".config/hypr/hyprland.lua".source = ../../../dotfiles/hyprland/hyprland.lua;
  xdg.configFile."hypr/hyprsunset.conf".source = ../../../dotfiles/hyprland/hyprsunset.conf;
  xdg.configFile."ashell/config.toml".source = ../../../dotfiles/ashell/config.toml;
}
