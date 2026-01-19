# Development tools and coding agents.
{pkgs, ...}: {
  home.packages = with pkgs; [
    claude-code
    hunk
    hyperfine
    jujutsu
    pi-coding-agent
    tokei
  ];
}
