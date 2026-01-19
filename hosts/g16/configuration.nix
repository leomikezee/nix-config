{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop-enviroment.nix
    ../../modules/gaming.nix
    ../../modules/working.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  time.timeZone = "America/Toronto";

  networking.hostName = "g16";

  services.asusd.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    asusctl
    nvtopPackages.nvidia
  ];
}
