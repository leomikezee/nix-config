# Every host imports this, including headless servers: only put things here that
# belong on a machine without a screen.
{
  config,
  lib,
  pkgs,
  stateVersion,
  vars,
  ...
}: let
  # Single source of truth for binary caches: the flake's nixConfig.
  caches = (import ../flake.nix).nixConfig;
in {
  system.stateVersion = stateVersion;

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [vars.username];
      builders-use-substitutes = true;
      substituters = caches.extra-substituters;
      trusted-public-keys = caches.extra-trusted-public-keys;
    };

    optimise.automatic = true;
  };

  zramSwap.enable = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  time.timeZone = lib.mkDefault "America/Toronto";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["zh_CN.UTF-8/UTF-8"];
  };

  users.users.${vars.username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = vars.sshKeys;
  };

  networking = {
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      8080 # miniserve default port (package in modules/home/base.nix)
    ];
  };

  services.btrfs.autoScrub = lib.mkIf (config.fileSystems."/".fsType == "btrfs") {
    enable = true;
    fileSystems = ["/"];
  };

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  programs.fish.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/${vars.username}/Repositories/nix-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --no-gcroots";
    };
  };

  home-manager.sharedModules = [./home/base.nix];
}
