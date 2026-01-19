# University of Waterloo VPN (Cisco AnyConnect via openconnect), as a
# NetworkManager profile. Connect from the network menu or `nmcli con up "Waterloo VPN"`.
{pkgs, ...}: {
  networking.networkmanager = {
    plugins = [pkgs.networkmanager-openconnect];
    ensureProfiles.profiles.WaterlooVPN = {
      connection = {
        id = "Waterloo VPN";
        type = "vpn";
        autoconnect = "false";
      };
      vpn = {
        service-type = "org.freedesktop.NetworkManager.openconnect";
        gateway = "cn-vpn.uwaterloo.ca";
        username = "m7liao";
        protocol = "anyconnect";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        method = "auto";
        addr-gen-mode = "stable-privacy";
      };
    };
  };

  environment.systemPackages = [pkgs.openconnect];
}
