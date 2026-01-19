{
  config,
  pkgs,
  stateVersion,
  vars,
  ...
}: {
  system.stateVersion = stateVersion;

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [vars.username];
      builders-use-substitutes = true;
      substituters = [
        "https://mirrors.cernet.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos-cuda.org"
        "https://fcitx5-vinput.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "fcitx5-vinput.cachix.org-1:XpX3AA6+dDIX4qJhb1QM7sbTwX6/qSlGvW8Z5NK6XdU="
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["zh_CN.UTF-8/UTF-8"];
  };

  users.users.${vars.username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = ["wheel" "networkmanager" "video" "input" "libvirtd" "incus-admin"];
  };

  networking = {
    nftables.enable = true;
    firewall = {
      allowedTCPPorts = [3030 8080 21118];
      trustedInterfaces = ["virbr0" "incusbr0"];
    };
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
      ensureProfiles.profiles = {
        WaterlooVPN = {
          connection = {
            id = "Waterloo VPN";
            type = "vpn";
            autoconnect = "false";
          };
          vpn = {
            service-type = "org.freedesktop.NetworkManager.openconnect";
            gateway = "cn-vpn.uwaterloo.ca";
            username = "m7liao";
            protocol = "anyconnect";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
          };
        };
      };
    };
  };

  virtualisation.podman.enable = true;

  services.daed = {
    enable = true;
    openFirewall = {
      enable = true;
      port = 12345;
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
          otherlayer = {};
        };
        extraConfig = ''
        '';
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services = {
    flatpak.enable = true;
    gvfs.enable = true;
    power-profiles-daemon.enable = true;
    tailscale.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    usbmuxd.enable = true;
  };

  systemd.user.services.tailscale-systray = {
    description = "Tailscale system tray icon";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session-pre.target"];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
      Restart = "on-failure";
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    pulseaudio
  ];
}
