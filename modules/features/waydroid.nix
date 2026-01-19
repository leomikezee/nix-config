# Waydroid: Android apps in a container.
{pkgs, ...}: {
  boot.kernelModules = ["binder_linux"];

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
}
