# RetroArch and its networking ports.
{
  networking.firewall = {
    allowedTCPPorts = [55435];
    allowedUDPPorts = [55355 55400 55401 55402 55403 55404 55405 55435];
  };

  home-manager.sharedModules = [../home/features/retro-gaming.nix];
}
