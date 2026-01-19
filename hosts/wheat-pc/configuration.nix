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
    ../../modules/graphical/mango.nix
    ./hardware-configuration.nix
    ./vpn-gateway.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.resumeDevice = "/dev/disk/by-uuid/37478cd8-f765-4852-97ae-340ef309d3eb";

  # Allow browser access through WebHID to the VXE mouse via ATK Hub at hub.atk.pro
  # and to the MiraBox K1 Pro.
  # 73-seat-late.rules converts the uaccess tag into a user ACL.
  # Set the tag before that rule runs. services.udev.extraRules uses 99-local.rules.
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-hid-uaccess.rules" ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="373b", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="6603", TAG+="uaccess"
    '')
  ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "boot2win" ''
      set -euo pipefail
      echo "Setting next boot to Windows..."
      ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0001
      echo "Rebooting into Windows..."
      ${pkgs.systemd}/bin/systemctl reboot
    '')
    efibooteditor
    efibootmgr
    nvtopPackages.nvidia
  ];
}
