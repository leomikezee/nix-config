# VPN gateway for devices without daed.
#
# A device on the LAN that can't run daed itself can still use the proxy by
# routing its traffic through wheat-pc: on that device, set the default gateway
# (and DNS) to wheat-pc's LAN IP. daed (modules/features/daed.nix) then picks up the
# forwarded traffic, provided `lanInterface` is bound as a LAN interface in the
# daed dashboard.
#
# Trade-off: trusting the interface disables the firewall for the whole LAN, so
# every service listening on wheat-pc is reachable from any device on it.
_: let
  lanInterface = "enp5s0";
in {
  # The gateway is useless without daed doing the proxying.
  imports = [../../modules/features/daed.nix];

  # Forward traffic from LAN clients instead of dropping it.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Let LAN clients reach daed and wheat-pc's DNS without per-port rules.
  networking.firewall.trustedInterfaces = [lanInterface];
}
