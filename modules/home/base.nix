# Home config for every host, including headless servers. Registered by
# modules/base.nix, so hosts don't import it themselves.
{
  inputs,
  lib,
  pkgs,
  hostname,
  stateVersion,
  vars,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];

  home = {
    inherit (vars) username;
    homeDirectory = "/home/${vars.username}";
    inherit stateVersion;
  };

  home.packages = with pkgs; [
    bat
    bindfs
    bottom
    dust
    fastfetch
    fd
    fuse3
    jq
    just
    miniserve # port 8080 is opened in modules/base.nix
    nixd
    ripgrep
    ripunzip
    sshfs # used by the yazi sshfs plugin below
    tailcat
    wget
  ];

  xdg.configFile."fastfetch".source = ../../dotfiles/fastfetch;

  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "blue";
    flavor = "mocha";
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

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    enableGitIntegration = true;
    nix-direnv.enable = true;
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
    languages = {
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
    settings = {
      editor = {
        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 1000;
          };
        };
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
    # GNU ld rejects overlapping .eh_frame entries in the bundled Zig-built
    # libghostty-vt; use LLD for Rust's final link instead.
    package = pkgs.herdr.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [(lib.getBin pkgs.llvmPackages.lld)];
      env = (old.env or {}) // {RUSTFLAGS = "-C link-arg=-fuse-ld=lld";};
    });
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
    settings = {
      promptToReturnFromSubprocess = false;
      git = {
        diffRenderers = [
          {
            command = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
        ];
      };
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      hostname.ssh_only = false;
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
      inherit lazygit;
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
    # Works without a display; home/graphical/default.nix switches to a GUI prompt.
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
  };

  programs.home-manager.enable = true;
}
