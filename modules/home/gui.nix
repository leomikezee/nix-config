{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    deskflow
    google-chrome
    kitty
    remmina
    vesktop
    vscode
    wechat
  ];

  home.file.".config/kitty/quick-access-terminal.conf".source = ./dotfiles/quick-access-terminal.conf;
  # home.file.".config/niri/config.kdl".source = ./dotfiles/config.kdl;
  home.file."rime/default.custom.yaml".source = ./dotfiles/default.custom.yaml;
}
