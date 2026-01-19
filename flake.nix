{
  description = "Maizi's Infra Flake";

  nixConfig = {
    extra-substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
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

    catppuccin.url = "github:catppuccin/nix";

    daeuniverse.url = "github:daeuniverse/flake.nix";

    fcitx5-vinput = {
      url = "github:xifan2333/fcitx5-vinput";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    vars = {
      username = "liaomaizi";
      fullName = "Maizi Liao";
      email = "liaomaizi@gmail.com";
    };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkNixOS = {
      hostname,
      system,
      stateVersion,
      modules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs vars stateVersion;};
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.username} = {
                  imports = [
                    ./hosts/${hostname}/home.nix
                    inputs.catppuccin.homeModules.catppuccin
                  ];
                };
                extraSpecialArgs = {inherit vars stateVersion;};
                backupFileExtension = "backup";
              };
            }
            inputs.catppuccin.nixosModules.catppuccin
            inputs.daeuniverse.nixosModules.daed
          ]
          ++ modules;
      };
  in {
    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );

    nixosConfigurations = {
      g16 = mkNixOS {
        hostname = "g16";
        system = "x86_64-linux";
        stateVersion = "26.05";
      };
      matebook-14s = mkNixOS {
        hostname = "matebook-14s";
        system = "x86_64-linux";
        stateVersion = "26.05";
      };
      macbook-pro-15 = mkNixOS {
        hostname = "macbook-pro-15";
        system = "x86_64-linux";
        stateVersion = "26.05";
      };
      wheat-pc = mkNixOS {
        hostname = "wheat-pc";
        system = "x86_64-linux";
        stateVersion = "26.05";
      };
    };
  };
}
