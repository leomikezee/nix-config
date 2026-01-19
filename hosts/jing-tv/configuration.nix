{pkgs, ...}: {
  imports = [
    ../../modules/features/dae.nix
    ../../modules/features/gaming.nix
    ../../modules/features/music.nix
    ../../modules/features/retro-gaming.nix
    ../../modules/features/sunshine.nix
    ../../modules/features/waydroid.nix
    ../../modules/graphical/bigscreen.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
