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

  boot.kernelParams = [
    # Force VESA AUX/DPCD brightness control for the OLED/mini-LED panel
    "xe.enable_dpcd_backlight=1"
    "i915.enable_dpcd_backlight=1"

    # Stop Nvidia from hijacking the backlight interface on hybrid graphics
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];

  time.timeZone = "America/Toronto";

  networking.hostName = "g16";

  services.asusd.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:2@0:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    asusctl
    brightnessctl
    nvtopPackages.nvidia
  ];
}
