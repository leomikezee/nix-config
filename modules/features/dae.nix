{vars, ...}: {
  services.dae = {
    enable = true;
    configFile = "/home/${vars.username}/.config/dae/config.dae";
  };
}
