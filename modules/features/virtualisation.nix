# Containers (podman) and VMs (libvirt + virt-manager).
{vars, ...}: {
  virtualisation = {
    podman.enable = true;
    libvirtd.enable = true;
  };

  programs.dconf.enable = true;

  # Update containers that opt in with the io.containers.autoupdate label.
  systemd.timers.podman-auto-update = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  home-manager.sharedModules = [../home/features/virtualisation.nix];

  # Membership in libvirtd is root-equivalent.
  users.users.${vars.username}.extraGroups = ["libvirtd"];

  # libvirt's default NAT network; guests need DHCP/DNS from the host.
  networking.firewall.trustedInterfaces = ["virbr0"];
}
