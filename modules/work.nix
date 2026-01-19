{
  config,
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
}
