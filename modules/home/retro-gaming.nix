{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [];
  programs.retroarch = {
    enable = true;
    cores = {
      fbneo.enable = true;
      mame2003-plus.enable = true;
    };
  };
}
