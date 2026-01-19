{
  config,
  pkgs,
  stateVersion,
  vars,
  ...
}: {
  imports = [
    ../../modules/home/cli.nix
    ../../modules/home/gui.nix
    ../../modules/home/retro-gaming.nix
  ];

  home = {
    inherit (vars) username;
    homeDirectory = "/home/${vars.username}";
    inherit stateVersion;
  };

  home.packages = with pkgs; [];
}
