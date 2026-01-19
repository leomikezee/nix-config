{pkgs, ...}: {
  home.packages = [pkgs.wpsoffice-cn];

  imports = [
    ../../modules/home/features/apps.nix
    ../../modules/home/features/claude-vpn.nix
    ../../modules/home/features/dev.nix
  ];

  programs.claude-vpn.enable = true;
}
