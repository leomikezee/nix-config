{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/graphical/niri.nix
    ../../modules/features/daed.nix
    ../../modules/features/gaming.nix
    ../../modules/features/virtualisation.nix
    ../../modules/features/waydroid.nix
  ];

  environment.systemPackages = with pkgs; [
    gpu-switch
  ];
}
