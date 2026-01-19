# Syncthing between the hosts listed below. Import this only on those hosts;
# a host that isn't listed here isn't accepted by the others.
{vars, ...}: {
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "wheat-pc" = {
          id = "TSL5N3V-WMA62IV-UQ3WICK-QLVGFVR-B5VSOY7-FLGDBGA-4RQ5JFP-UPCXPAD";
        };
        "g16" = {
          id = "J3W2RBF-XDTCJXZ-UQCJCYV-VMIY46Z-65Z6P7T-7S6OZAB-YJFEU5A-PJK2AAF";
        };
      };
      folders = {
        "cyita-fkkws" = {
          label = "Repos";
          path = "/home/${vars.username}/Repositories/Sync";
          devices = [
            "g16"
            "wheat-pc"
          ];
        };
      };
    };
  };
}
