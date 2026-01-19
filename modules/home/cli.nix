{
  config,
  pkgs,
  vars,
  ...
}: {
  home.packages = with pkgs; [
    bat
    bindfs
    bottom
    claude-code
    cron
    dotool
    dust
    fastfetch
    fd
    herdr
    hunk
    hyperfine
    jq
    jujutsu
    just
    libimobiledevice
    miniserve
    nixd
    openconnect
    pi-coding-agent
    ripgrep
    ripunzip
    tailcat
    tokei
    uv
    wget
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat -p --paging=never";
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
    historyWidget.command = "";
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

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  programs.lazygit = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings.updates.auto_update = true;
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.home-manager.enable = true;
}
