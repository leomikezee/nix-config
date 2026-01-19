# User applications. Registered by modules/features/work.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    github-copilot-cli
    mattermost-desktop
  ];
}
