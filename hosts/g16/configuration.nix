{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/features/dae.nix
    ../../modules/features/gaming.nix
    ../../modules/features/lan-mouse.nix
    ../../modules/features/music.nix
    ../../modules/features/obs.nix
    ../../modules/features/sunshine.nix
    ../../modules/features/virtualisation.nix
    ../../modules/features/waydroid.nix
    ../../modules/features/work.nix
    ../../modules/graphical/umbriel.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    # Force VESA AUX/DPCD brightness control for the OLED/mini-LED panel
    "xe.enable_dpcd_backlight=1"
    "i915.enable_dpcd_backlight=1"

    # Disable NVIDIA backlight control on hybrid graphics
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/4407a387-1f93-49c4-a1d6-eb1094b3693e";

  services.asusd.enable = true;

  # Filter micro-jitter on finger release (e.g. scroll-back) for the FocalTech
  # (2808:0219) touchpad, which reports fuzz=0 by default.
  services.udev.extraHwdb = ''
    evdev:name:ASUF1209:00 2808:0219 Touchpad:dmi:*:svnASUS:pnROGZephyrusG16GU606AP:*
     EVDEV_ABS_00=:::13
     EVDEV_ABS_01=:::13
     EVDEV_ABS_35=:::13
     EVDEV_ABS_36=:::13
  '';

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
    # Use RTD3 to power off the discrete GPU when idle. This requires PRIME offload.
    powerManagement.finegrained = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
