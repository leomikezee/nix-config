# User configuration for development tools. Imported by hosts' home.nix.
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
    hyperfine
    leaf-markdown-viewer
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
