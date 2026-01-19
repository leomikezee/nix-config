{
  description = "Maizi's Infra Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fcitx5-vinput.url = "github:xifan2333/fcitx5-vinput";
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
      stateVersion = "25.05";
    };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkNixOS = {
      hostname,
      system,
      modules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs vars;};
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.username} = import ./hosts/${hostname}/home.nix;
                extraSpecialArgs = {inherit vars;};
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

    nixConfig = {
      extra-substituters = ["https://fcitx5-vinput.cachix.org"];
      extra-trusted-public-keys = ["fcitx5-vinput.cachix.org-1:XpX3AA6+dDIX4qJhb1QM7sbTwX6/qSlGvW8Z5NK6XdU="];
    };

    nixosConfigurations = {
      matebook-14s = mkNixOS {
        hostname = "matebook-14s";
        system = "x86_64-linux";
      };
      macbook-pro-15 = mkNixOS {
        hostname = "macbook-pro-15";
        system = "x86_64-linux";
      };
      wheat-pc = mkNixOS {
        hostname = "wheat-pc";
        system = "x86_64-linux";
      };
    };
  };
}
