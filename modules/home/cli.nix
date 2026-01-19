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
    fuse3
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
    sshfs
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
        inherit (vars) email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        default-yank-register = "+";
        indent-guides = {
          render = true;
          character = "┆";
        };
      };
    };
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
    keymap.mgr.prepend_keymap = [
      {
        on = ["M" "s"];
        run = "plugin sshfs -- menu";
        desc = "Open SSHFS options";
      }
      {
        on = ["g" "i"];
        run = "plugin lazygit";
        desc = "run lazygit";
      }
    ];
    plugins = with pkgs.yaziPlugins; {
      git = {
        package = git;
        setup = true;
      };
      lazygit = lazygit;
      sshfs = {
        package = sshfs;
        setup = true;
      };
      starship = {
        package = starship;
        setup = true;
      };
    };
    settings.plugin.prepend_fetchers = [
      {
        url = "*";
        run = "git";
        group = "git";
      }
      {
        url = "*/";
        run = "git";
        group = "git";
      }
    ];
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
