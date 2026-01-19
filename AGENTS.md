# Contributor and Agent Guidelines

These guidelines apply to the entire repository, for both human contributors and
coding agents. See [README.md](README.md) for setup, repository layout, host creation
and activation instructions.

## Nix Style

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

## Choosing a Module or Package

First, decide where it belongs:

- Use **NixOS** for system setup: hardware, networking, services, permissions, users,
  login shells and desktop sessions.
- Use **home-manager** for your apps, command-line tools and personal settings.
  This is the usual choice unless something needs system setup.

Then, decide how to add it:

- Use a **module** when it provides settings or integration you need.
- Add a **package** when you only need the program installed.

|                | Settings or integration | Install only                 |
| -------------- | ----------------------- | ---------------------------- |
| **System**     | NixOS module            | `environment.systemPackages` |
| **Your user**  | home-manager module     | `home.packages`              |

For example, enable SSH and PipeWire through NixOS modules, configure Git through
home-manager, and add tools like `ripgrep` and `jq` to `home.packages`.

A few things to check:

- **Does the module install the package?** Many application modules do, but not all.
  Check before adding the same package separately.
- **Do both NixOS and home-manager have a module?** Use home-manager unless you also
  need system setup. Fish uses both here: NixOS makes it available as a login shell,
  and home-manager configures aliases and plugins.
- **Is there no suitable module?** Install the package and, if needed, link its config
  from `dotfiles/` with `xdg.configFile`.

Keep `environment.systemPackages` for system administration and rescue tools.
Put project-specific compilers and other development tools in that project's `devShell`.

## Package Placement

- **Every host**: `modules/base.nix` (system) or `modules/home/base.nix` (user)
- **Hosts with a screen**: `modules/graphical/default.nix` or `modules/home/graphical/default.nix`
- **One capability**: the matching module in `modules/features/` or `modules/home/features/`
- **One host**: `hosts/HOSTNAME/configuration.nix` or `hosts/HOSTNAME/home.nix`

## Module Boundaries

`modules/features/` and `modules/home/features/` share an organizational structure,
but features do not require matching modules:

- **User configuration only**: create only `modules/home/features/NAME.nix` and
  import it from the relevant hosts' `home.nix`.
- **System configuration only**: create only `modules/features/NAME.nix` and
  import it from the relevant hosts' `configuration.nix`.
- **Needs both**: create both modules. When they should always be enabled together,
  register the home-manager module through the system module's
  `home-manager.sharedModules`.

Do not create empty counterparts or forwarding wrappers solely to preserve symmetry.

Put a service's firewall ports, user groups and trusted interfaces in the module that
enables the service, not in a shared file. Then import the module from the hosts that
need it (features), or from a role/session module if every such host needs it.

## Validation

- For Nix changes, run `nix fmt .` before committing, then `nix flake check` to check
  formatting, deadnix, statix and evaluation of every host.
- New files must be tracked by Git before Nix flakes can see them. Account for this
  when validating new modules; do not stage unrelated changes.
- Review [HOTFIXES.md](HOTFIXES.md) after updating inputs for temporary fixes,
  workarounds and their removal conditions.
- Activation is not validation: `nh os switch` and `nixos-rebuild switch` change the
  running system. Agents must not run them unless the user explicitly requests activation.
