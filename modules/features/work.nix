{
  pkgs,
  vars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    github-copilot-cli
    mattermost-desktop
  ];

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };

  # Membership in incus-admin is root-equivalent.
  users.users.${vars.username}.extraGroups = ["incus-admin"];

  # Incus' default bridge; instances need DHCP/DNS from the host.
  networking.firewall.trustedInterfaces = ["incusbr0"];
}
