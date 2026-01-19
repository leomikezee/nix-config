{pkgs, ...}: {
  home.packages = [pkgs.wpsoffice-cn];

  imports = [
    ../../modules/home/features/claude-vpn.nix
  ];

  programs.claude-vpn.enable = true;
}
