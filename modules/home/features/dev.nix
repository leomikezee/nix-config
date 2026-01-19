# User configuration for development tools. Registered by modules/features/dev.nix.
{
  lib,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
in {
  programs.delta.enableJujutsuIntegration = true;
  programs.jujutsu.enable = true;
  programs.pi-coding-agent.enable = true;

  home.packages = with pkgs; [
    claude-code
    hunk
    hyperfine
    mcp-nixos
    tokei
  ];

  home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp.json" {
    mcpServers.nixos = {
      command = lib.getExe pkgs.mcp-nixos;
      description = "Search NixOS packages and options, Home Manager options, and Nix documentation.";
    };
  };
}
