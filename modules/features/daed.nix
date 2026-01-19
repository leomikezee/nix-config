# daed: transparent proxy (dae) with a web dashboard.
{inputs, ...}: {
  imports = [inputs.daeuniverse.nixosModules.daed];

  services.daed = {
    enable = true;
    openFirewall = {
      enable = true;
      port = 12345;
    };
  };
}
