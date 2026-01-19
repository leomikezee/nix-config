{pkgs, ...}: {
  imports = [
    ../../modules/features/apps.nix
    ../../modules/features/dae.nix
    ../../modules/features/dev.nix
    ../../modules/features/gaming.nix
    ../../modules/features/music.nix
    ../../modules/features/sunshine.nix
    ../../modules/features/virtualisation.nix
    ../../modules/features/waydroid.nix
    ../../modules/graphical/niri.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    gpu-switch
  ];
}
