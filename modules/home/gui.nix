{
  config,
  pkgs,
  vars,
  ...
}: {
  home.packages = with pkgs; [
    anydesk
    art
    celluloid
    deskflow
    godot
    google-chrome
    obsidian
    remmina
    vesktop
    vscode
    # warp-terminal
    wechat
  ];

  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        "wheat-pc" = {
          id = "TSL5N3V-WMA62IV-UQ3WICK-QLVGFVR-B5VSOY7-FLGDBGA-4RQ5JFP-UPCXPAD";
        };
        "g16" = {
          id = "WEMEAIM-XT7VNMW-5DWVR5A-OA7YKUV-7MWTIMO-XVJBIZ6-Z2RSMXU-W2KIUAB";
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
    shellIntegration.enableFishIntegration = true;
    quickAccessTerminalConfig = {
      lines = 48;
      margin_left = 512;
      margin_right = 512;
    };
  };

  home.file.".config/niri/config.kdl".source = ./dotfiles/config.kdl;
  home.file."rime/default.custom.yaml".source = ./dotfiles/default.custom.yaml;
}
