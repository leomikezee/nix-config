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
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  time.timeZone = "America/Toronto";

  networking.hostName = "wheat-pc";

  systemd.services.disable-acpi-wakeup = {
    description = "Disable ACPI wakeup devices (e.g., XHC, LID0)";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c 'echo GPP0 > /proc/acpi/wakeup'";
      RemainAfterExit = true;
    };
  };

  # ATK Hub support for VXE mouse
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="373b", MODE="0666"
  '';

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
