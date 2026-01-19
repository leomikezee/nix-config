{
  config,
  pkgs,
  vars,
  inputs,
  ...
}: let
  fcitx5-vinput = inputs.fcitx5-vinput.packages."${pkgs.stdenv.hostPlatform.system}".default;
in {
  nixpkgs.overlays = [
    (final: prev: {
      librime = prev.librime.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../patches/rime-fix-input.patch];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    fcitx5-vinput
    nautilus
    wl-clipboard-rs
    xdg-terminal-exec
    xwayland-satellite
  ];

  environment.sessionVariables = {
    XIM = "fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
  };

  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # for waydroid
  boot.kernelModules = ["binder_linux"];

  virtualisation = {
    podman.enable = true;
    waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  # services.displayManager.dms-greeter = {
  #   enable = true;
  #   compositor.name = "niri";
  #   configHome = "/home/${vars.username}";
  #   logs = {
  #     save = true;
  #     path = "/tmp/dms-greeter.log";
  #   };
  # };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  services.gvfs.enable = true;

  services.upower.enable = true;

  services.power-profiles-daemon.enable = true;

  services.usbmuxd.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  services.v2raya.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;
      addons = with pkgs; [
        kdePackages.fcitx5-qt
        fcitx5-fluent
        fcitx5-gtk
        (fcitx5-rime.override {
          rimeDataPkgs = [
            pkgs.rime-ice
          ];
        })
        fcitx5-vinput
      ];
      settings = {
        inputMethod = {
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
  };

  programs.kdeconnect.enable = true;
  programs.niri.enable = true;
  programs.dms-shell.enable = true;
}
