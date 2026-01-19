{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/graphical/niri.nix
    ../../modules/features/dae.nix
    ../../modules/features/gaming.nix
    ../../modules/features/virtualisation.nix
    ../../modules/features/waydroid.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    gpu-switch
  ];
}
