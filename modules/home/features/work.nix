# Work applications and settings. Registered by modules/features/work.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    github-copilot-cli
    mattermost-desktop
  ];

  programs.git.includes = [
    {
      condition = "hasconfig:remote.*.url:git@github.com:canonical/**";
      contents.user.email = "maizi.liao@canonical.com";
    }
    {
      condition = "hasconfig:remote.*.url:https://github.com/canonical/**";
      contents.user.email = "maizi.liao@canonical.com";
    }
    {
      condition = "hasconfig:remote.*.url:ssh://git@github.com/canonical/**";
      contents.user.email = "maizi.liao@canonical.com";
    }
  ];
}
