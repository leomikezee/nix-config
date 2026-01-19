# File-sharing CLI. Registered by modules/features/miniserve.nix.
{pkgs, ...}: {
  home.packages = [pkgs.miniserve];
}
