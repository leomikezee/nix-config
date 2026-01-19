{
  config,
  pkgs,
  vars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    github-copilot-cli
    mattermost-desktop
    pi-coding-agent
  ];

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };
}
