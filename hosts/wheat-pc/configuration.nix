{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./vpn-gateway.nix
    # ../../modules/graphical/niri.nix
    ../../modules/graphical/hyprland.nix
    ../../modules/features/daed.nix
    ../../modules/features/gaming.nix
    ../../modules/features/virtualisation.nix
    ../../modules/features/waterloo-vpn.nix
    ../../modules/features/waydroid.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Let the logged-in user open these HID devices from the browser (WebHID):
  # ATK Hub (hub.atk.pro) for the VXE mouse, and the MiraBox K1 Pro.
  # The uaccess tag is turned into a user ACL by 73-seat-late.rules, so it must be
  # set in a file sorted before it; services.udev.extraRules lands in 99-local.rules.
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
    efibootmgr
    nvtopPackages.nvidia
    (pkgs.writeShellScriptBin "boot2win" ''
      set -euo pipefail
      echo "Setting next boot to Windows..."
      ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0001
      echo "Rebooting into Windows..."
      ${pkgs.systemd}/bin/systemctl reboot
    '')
  ];
}
