# Containers (podman) and VMs (libvirt + virt-manager).
{vars, ...}: {
  virtualisation = {
    podman.enable = true;
    libvirtd.enable = true;
  };

  programs.virt-manager.enable = true;

  # Membership in libvirtd is root-equivalent.
  users.users.${vars.username}.extraGroups = ["libvirtd"];

  # libvirt's default NAT network; guests need DHCP/DNS from the host.
  networking.firewall.trustedInterfaces = ["virbr0"];
}
