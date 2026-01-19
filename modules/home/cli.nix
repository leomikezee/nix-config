{
  config,
  pkgs,
  vars,
  ...
}: {
  home.packages = with pkgs; [
    bat
    bottom
    claude-code
    cron
    delta
    dotool
    dust
    eza
    fastfetch
    fd
    fzf
    helix
    hyperfine
    jujutsu
    just
    libimobiledevice
    miniserve
    nixd
    opencode
    openconnect
    ripgrep
    ripunzip
    tealdeer
    tokei
    wget
    yazi
    zellij
    zoxide
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza -T";
    };
    interactiveShellInit = ''
      starship init fish | source
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = vars.fullName;
        email = vars.email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  programs.uv = {
    enable = true;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.home-manager.enable = true;
}
