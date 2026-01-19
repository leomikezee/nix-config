# Ad-hoc file sharing; keep the CLI and its default port together.
{
  networking.firewall.allowedTCPPorts = [8080];

  home-manager.sharedModules = [../home/features/miniserve.nix];
}
