# Run Android apps in a Waydroid container.
{pkgs, ...}: {
  boot.kernelModules = ["binder_linux"];

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
}
