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

  time.timeZone = "America/Toronto";

  networking.hostName = "macbook-pro-15";

  environment.systemPackages = with pkgs; [
    gpu-switch
  ];
}
