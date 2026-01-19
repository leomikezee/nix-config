# Home config for hosts with a screen. Registered by modules/graphical/default.nix.
{
  inputs,
  pkgs,
  ...
}: let
  fcitx5-vinput = inputs.fcitx5-vinput.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.packages = with pkgs; [
    adwaita-icon-theme
    brightnessctl
    cliamp
    gnome-pomodoro
    libimobiledevice # iOS client tools; services.usbmuxd remains in NixOS
    moonlight-qt
    nautilus
    pulseaudio # pactl client; the sound server is PipeWire
    wl-clipboard-rs
    xdg-terminal-exec
    xwayland-satellite
  ];

  services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  xsession.preferStatusNotifierItems = true;

  services.network-manager-applet.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
    x11.enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
      size = 12;
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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      systemd.enable = true;
      addons = with pkgs; [
        fcitx5-fluent
        fcitx5-gtk
        (fcitx5-rime.override {
          rimeDataPkgs = [pkgs.rime-ice];
        })
        fcitx5-vinput
        kdePackages.fcitx5-qt
      ];
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "keyboard-us";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "rime";
      };
    };
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = ../../../dotfiles/rime/default.custom.yaml;
}
