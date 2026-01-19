{
  imports = [
    ../../modules/home/features/claude-vpn.nix
    ../../modules/home/features/syncthing.nix
  ];

  programs.claude-vpn.enable = true;
}
