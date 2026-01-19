# User configuration for RetroArch. Registered by modules/features/retro-gaming.nix.
_: {
  programs.retroarch = {
    enable = true;
    cores = {
      fbneo.enable = true;
      mame2003-plus.enable = true;
      mgba.enable = true;
      swanstation.enable = true;
    };
  };
}
