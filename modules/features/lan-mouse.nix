# Mouse and keyboard sharing; keep the app and its default UDP port together.
{
  networking.firewall.allowedUDPPorts = [4242];

  home-manager.sharedModules = [../home/features/lan-mouse.nix];
}
