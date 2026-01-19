# Role for hosts with a screen. Hosts don't import this directly: each session
# module (niri.nix, bigscreen.nix) imports it, so a host picks just its session.
{
  pkgs,
  inputs,
  vars,
  ...
}: let
  fcitx5-vinput = inputs.fcitx5-vinput.packages."${pkgs.stdenv.hostPlatform.system}".default;
in {
  imports = [../base.nix];

  nixpkgs.overlays = [
    (_: prev: {
      librime = prev.librime.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../../patches/rime-fix-input.patch];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    fcitx5-vinput
    moonlight-qt
    nautilus
    pulseaudio # for pactl; the sound server itself is pipewire
    wl-clipboard-rs
    xdg-terminal-exec
    xwayland-satellite
  ];

  users.users.${vars.username}.extraGroups = ["networkmanager" "video" "input"];

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  security.rtkit.enable = true;

  networking.networkmanager = {
    enable = true;
    plugins = [pkgs.networkmanager-openvpn];
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      adwaita-fonts
      fira-code
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      (pkgs.runCommand "pingfang-sc" {
          src = pkgs.fetchFromGitHub {
            owner = "shenweiyan";
            repo = "PingFangSC-Fonts";
            rev = "b9484836f50a585a821469f29e2e5c4feaf86c7d";
            hash = "sha256-U7lvls98TFvwuLm58aRj6bEtpT7pNk5N/3te0MumDb4=";
          };
        } ''
          mkdir -p $out/share/fonts/truetype
          cp $src/*.ttf $out/share/fonts/truetype/
        '')
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = "*";
  };

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
        # globalOptions = {
        #   "Hotkey/TriggerKeys"."0" = "Super+space";
        # };
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

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "layer(control)";
          };
        };
      };
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    # FFmpeg loads the NVIDIA CUDA/NVENC libraries with dlopen(). Sunshine's
    # capability wrapper runs in secure-execution mode, so LD_LIBRARY_PATH is
    # ignored; put the NixOS driver link in the executable's RUNPATH instead.
    package =
      pkgs.runCommand "${pkgs.sunshine.name}-driver-runpath" {
        nativeBuildInputs = [pkgs.patchelf];
        inherit (pkgs.sunshine) meta;
      } ''
        mkdir -p "$out"
        cp -a ${pkgs.sunshine}/. "$out/"
        chmod u+w "$out/bin/sunshine"
        patchelf --add-rpath ${pkgs.addDriverRunpath.driverLink}/lib "$out/bin/sunshine"
      '';
  };

  services = {
    flatpak.enable = true;
    gvfs.enable = true;
    power-profiles-daemon.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    usbmuxd.enable = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.kdeconnect.enable = true;

  programs.nm-applet.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  home-manager.sharedModules = [../home/graphical/default.nix];
}
