# User configuration for development tools. Imported by hosts' home.nix.
{
  hostname,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
in {
  home.packages = with pkgs; [
    claude-code
    gh
    godot
    hyperfine
    leaf-markdown-viewer
    nixd
    tokei
    vscode
  ];

  programs.delta.enableJujutsuIntegration = true;

  programs.fish.shellAliases.pic = "pi --tools +codemode";

  programs.helix.languages = {
    language-server.nixd = {
      command = "${pkgs.nixd}/bin/nixd";
      config.nixd.options.home-manager.expr = ''(builtins.getFlake "/home/${vars.username}/Repositories/nix-config").nixosConfigurations.${hostname}.options.home-manager.users.type.getSubOptions []'';
    };
    language = [
      {
        name = "nix";
        language-servers = ["nixd"];
      }
    ];
  };

  programs.herdr = {
    enable = true;
    settings = {
      experimental.kitty_graphics = true;
      onboarding = false;
      theme = {
        auto_switch = false;
        name = "terminal";
      };
      ui = {
        show_agent_labels_on_pane_borders = true;
        toast.delivery = "system";
      };
    };
  };

  programs.jujutsu.enable = true;

  programs.pi-coding-agent.enable = true;

  home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp.json" {
    mcpServers.nixos = {
      command = lib.getExe pkgs.mcp-nixos;
      description = "Search NixOS packages and options, Home Manager options, and Nix documentation.";
    };
  };
}
