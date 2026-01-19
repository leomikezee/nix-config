{pkgs, ...}: {
  imports = [
    ../../modules/home/features/retro-gaming.nix
  ];

  home.packages = [pkgs.google-chrome];
}
