{
  config,
  pkgs,
  vars,
  ...
}: {
  home.packages = with pkgs; [
    ansel
    anydesk
    celluloid
    deskflow
    godot
    google-chrome
    imv
    obsidian
    remmina
    vesktop
    vscode
    # warp-terminal
    wechat
  ];

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "wheat-pc" = {
          id = "TSL5N3V-WMA62IV-UQ3WICK-QLVGFVR-B5VSOY7-FLGDBGA-4RQ5JFP-UPCXPAD";
        };
        "g16" = {
          id = "J3W2RBF-XDTCJXZ-UQCJCYV-VMIY46Z-65Z6P7T-7S6OZAB-YJFEU5A-PJK2AAF";
        };
      };
      folders = {
        "cyita-fkkws" = {
          label = "Repos";
          path = "/home/${vars.username}/Repositories/Sync";
          devices = [
            "g16"
            "wheat-pc"
          ];
        };
      };
    };
  };

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font = {
      name = "Fira Code";
      size = 14;
    };
    quickAccessTerminalConfig = {
      lines = 48;
      margin_left = 512;
      margin_right = 512;
    };
    settings = {
      disable_ligatures = "cursor";
    };
    shellIntegration.enableFishIntegration = true;
  };

  home.file.".config/niri/config.kdl".source = ./dotfiles/config.kdl;
  home.file."rime/default.custom.yaml".source = ./dotfiles/default.custom.yaml;
}
