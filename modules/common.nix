{
  config,
  pkgs,
  vars,
  ...
}: {
  system.stateVersion = vars.stateVersion;

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [vars.username];
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

  security.sudo.wheelNeedsPassword = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [8080];
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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["zh_CN.UTF-8/UTF-8"];
  };

  users.users.${vars.username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = ["wheel" "networkmanager" "input"];
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

  programs.fish.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [];
}
