# Contributor and agent guidelines

These guidelines apply to contributors and coding agents across the repository.
See [README.md](README.md) for setup, repository layout, adding hosts and activation.

## Nix style

- Alphabetize list items, including imports and packages. Preserve order when it
  affects behavior, such as command arguments, key sequences, bar layouts and icon scales.
  Keep trusted public keys in the corresponding substituter order.
- Within each file, keep program definitions alphabetically ordered by program name
  and service definitions alphabetically ordered by service name.
- Define each program or service separately using `programs.<name>` or
  `services.<name>`. Do not group multiple modules inside a shared `programs = { ... };`
  or `services = { ... };` block. Use a single-line assignment for one setting and
  a per-module block for multiple settings:
  ```nix
  programs.bat.enable = true;

  programs.git = {
    enable = true;
    settings.init.defaultBranch = "main";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;
  ```

## Choose a module or package

Choose where the configuration belongs:

- Use NixOS for hardware, networking, system services, permissions, users,
  login shells and desktop sessions.
- Use home-manager for your apps, command-line tools and personal settings.
  Use NixOS only when they need system setup.

Choose how to add the program:

- Use a module when you need its settings or integration.
- Add a package when you only need to install the program.

|                | Settings or integration | Install only                 |
| -------------- | ----------------------- | ---------------------------- |
| System         | NixOS module            | `environment.systemPackages` |
| Your user      | home-manager module     | `home.packages`              |

For example, enable SSH and PipeWire through NixOS modules, configure Git through
home-manager, and add tools like `ripgrep` and `jq` to `home.packages`.

Check the module before adding a package:

- Many application modules install their package, but not all do.
  Check before adding the same package separately.
- If both NixOS and home-manager have a module, use home-manager unless you need
  system setup. Fish uses both here. NixOS makes it available as a login shell,
  and home-manager configures aliases and plugins.
- If no suitable module exists, install the package. Use `xdg.configFile` to link
  its config from `dotfiles/` if needed.

Keep `environment.systemPackages` for system administration and rescue tools.
Put project-specific compilers and other development tools in that project's `devShell`.

## Package placement

- Put packages for every host in `modules/base.nix` for system tools or
  `modules/home/base.nix` for user tools.
- Put packages for hosts with a screen in `modules/graphical/default.nix` or
  `modules/home/graphical/default.nix`.
- Put packages for one capability in the matching module in `modules/features/`
  or `modules/home/features/`.
- Put packages for one host in `hosts/HOSTNAME/configuration.nix` or
  `hosts/HOSTNAME/home.nix`.

## Module boundaries

System features go in `modules/features/`. User features go in
`modules/home/features/`. A feature does not need a file in both directories.

- For user configuration only, create `modules/home/features/NAME.nix` and
  import it from the relevant hosts' `home.nix`.
- For system configuration only, create `modules/features/NAME.nix` and
  import it from the relevant hosts' `configuration.nix`.
- If a feature needs both, create both modules. When they should always be enabled
  together, register the home-manager module through the system module's
  `home-manager.sharedModules`.

Do not create empty counterparts or forwarding wrappers just to match the directories.

Put a service's firewall ports, user groups and trusted interfaces in the module that
enables the service, not in a shared file. Then import the module from the hosts that
need the feature, or from a role or session module if all hosts with that role or
session need it.

## Validation

- For Nix changes, run `nix fmt .` before committing, then `nix flake check` to check
  formatting, deadnix, statix and evaluation of every host.
- Track new files with Git before validating them. Nix flakes cannot see untracked
  files. Do not stage unrelated changes.
- Review [HOTFIXES.md](HOTFIXES.md) after updating inputs for temporary fixes,
  workarounds and their removal conditions.
- `nh os switch` and `nixos-rebuild switch` activate changes on the running system.
  They are not validation commands. Agents must not run them unless the user requests
  activation.
