# User tools and settings. Registered by modules/features/gaming.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    gamescope
    lutris
    protonplus
  ];

  # Overwatch shader cache.
  home.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };
}
