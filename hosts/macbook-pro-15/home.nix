{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ../../modules/home/cli.nix
    ../../modules/home/gui.nix
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;

  home.packages = with pkgs; [];
}
