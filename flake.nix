{
  description = "Maizi's Infra Flake";

  nixConfig = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://fcitx5-vinput.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "fcitx5-vinput.cachix.org-1:XpX3AA6+dDIX4qJhb1QM7sbTwX6/qSlGvW8Z5NK6XdU="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Not following nixpkgs on purpose: daed isn't in any binary cache, so following
    # would rebuild it on every nixpkgs update instead of only on daeuniverse updates.
    daeuniverse.url = "github:daeuniverse/flake.nix";

    fcitx5-vinput = {
      url = "github:xifan2333/fcitx5-vinput";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    vars = {
      username = "liaomaizi";
      fullName = "Maizi Liao";
      email = "liaomaizi@gmail.com";
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWKNbnA1vuLYwHyugSqEyJciKbEfY3mTuVKPmn7d7PC liaomaizi@wheat-pc"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIC3rXNCIs3TfWXqzTECfAy42dcgzLm/5wa8nskWcLqf liaomaizi@g16"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzH0M5luFDKPxV//eDumHiFX/nnuH0bNhI+IFYNW/RK liaomaizi@iphone17pm"
      ];
    };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkNixOS = {
      hostname,
      stateVersion ? "26.05", # release used for the host's initial installation
      modules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs vars stateVersion;};
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            {networking.hostName = hostname;}
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.username}.imports = [./hosts/${hostname}/home.nix];
                extraSpecialArgs = {inherit inputs vars stateVersion hostname;};
                backupFileExtension = "backup";
              };
            }
          ]
          ++ modules;
      };
  in {
    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );

    # Run by `nix flake check`, which also evaluates every host.
    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lint = name: script:
        pkgs.runCommand "check-${name}" {} ''
          cd ${./.}
          ${script}
          touch $out
        '';
    in {
      formatting = lint "formatting" "${pkgs.alejandra}/bin/alejandra --check --quiet .";
      # Generated hardware-configuration.nix files are left as nixos-generate-config wrote them.
      deadnix = lint "deadnix" ''
        find . -name '*.nix' ! -name hardware-configuration.nix -print0 \
          | xargs -0 ${pkgs.deadnix}/bin/deadnix --fail
      '';
      statix = lint "statix" "${pkgs.statix}/bin/statix check --config statix.toml .";
    });

    nixosConfigurations = nixpkgs.lib.genAttrs [
      "g16"
      "jing-tv"
      "macbook-pro-15"
      "matebook-14s"
      "wheat-pc"
    ] (hostname: mkNixOS {inherit hostname;});
  };
}
