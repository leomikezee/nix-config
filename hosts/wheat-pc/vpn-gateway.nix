# VPN gateway for devices without dae.
#
# To route a LAN device through wheat-pc, set its default gateway and DNS to
# wheat-pc's LAN IP. In the dae config, bind `lanInterface` as a LAN interface
# so dae handles the forwarded traffic. modules/features/dae.nix enables dae.
#
# Trusting this interface bypasses the firewall for incoming LAN traffic.
# LAN devices can reach any service listening on wheat-pc's LAN address.
_: let
  lanInterface = "enp10s0";
in {
  # The gateway needs dae to proxy traffic.
  imports = [../../modules/features/dae.nix];

  # Forward traffic from LAN clients instead of dropping it.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Let LAN clients reach dae and wheat-pc's DNS without per-port rules.
  networking.firewall.trustedInterfaces = [lanInterface];
}
