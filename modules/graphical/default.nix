# Shared desktop config for hosts with a screen. Hosts don't import this directly:
# each session module (mango, niri, umbriel, bigscreen) imports it.
{
  pkgs,
  vars,
  ...
}: {
  imports = [../base.nix];

  nixpkgs.overlays = [
    (_: prev: {
      librime = prev.librime.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../../patches/rime-fix-input.patch];
      });
    })
  ];

  users.users.${vars.username}.extraGroups = ["input" "networkmanager" "video"];

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
      maple-mono.NF-CN
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

  # D-Bus support for the NetworkManager applet managed by Home Manager.
  services.dbus.packages = [pkgs.gcr_3];

  services.flatpak.enable = true;

  services.gvfs.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "layer(control)";
            rightshift = "rightshift";
            rightcontrol = "rightcontrol";
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

  services.power-profiles-daemon.enable = true;

  # Device permissions belong to NixOS; the CLI is installed by Home Manager.
  services.udev.packages = [pkgs.brightnessctl];

  services.udisks2.enable = true;

  services.upower.enable = true;

  services.usbmuxd.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.kdeconnect.enable = true;

  home-manager.sharedModules = [../home/graphical/default.nix];
}
