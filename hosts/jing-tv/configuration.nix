{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/graphical/bigscreen.nix
    ../../modules/features/dae.nix
    ../../modules/features/gaming.nix
    ../../modules/features/waydroid.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # for retroarch
  networking.firewall = {
    allowedTCPPorts = [55435];
    allowedUDPPorts = [55355 55435 55400 55401 55402 55403 55404 55405];
  };
}
