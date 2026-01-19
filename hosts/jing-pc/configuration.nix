{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop-environment.nix
    ../../modules/gaming.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  time.timeZone = "America/Toronto";

  networking.hostName = "jing-pc";

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];
}
