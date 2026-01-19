# Nix Configuration

A modular, multi-host NixOS configuration using Flakes and home-manager.

## 🚀 Usage

### Initial Setup

1. Clone this repository:
   ```bash
   git clone <your-repo> ~/.config/nix-config
   cd ~/.config/nix-config
   ```

2. Generate hardware configuration:
   ```bash
   nixos-generate-config --show-hardware-config > hosts/HOSTNAME/hardware-configuration.nix
   # Or
   cp /etc/nixos/hardware-configuration.nix hosts/HOSTNAME/
   ```

3. Enable Nix's experimental features and add necessary packages:
   ```nix
   # Add to /etc/nixos/configuration.nix
   nix.settings.experimental-features = ["nix-command" "flakes"]
   environment.systemPackages = with pkgs; [
     vim
     git
   ];
   ```

4. Review and customize:
   - Update `vars` in `flake.nix` with your information
   - `stateVersion` defaults to `"26.05"` in `mkNixOS`; override it for hosts installed from another release
   - Adjust packages in module files
   - Configure host-specific settings

### Building and Activating

```bash
# Format, then check: formatting, deadnix, statix, and that every host evaluates
nix fmt .
nix flake check

# Update inputs when desired
nix flake update

# Build, show what changed, and activate (nh asks for sudo itself)
nh os switch .
# or
nh os switch -H .#HOSTNAME
# Without nh (e.g. on first install):
sudo nixos-rebuild switch --flake .#HOSTNAME
```

Old generations are cleaned weekly by `nh clean` (older than 7 days; the current one is kept).

New files must be tracked by git (`git add`) before Nix can see them.

## 🗂️ Layout

Each host picks **one session** (which brings its role and the base), plus **any number of features**.

```
flake.nix                 # inputs, vars, mkNixOS, host list
hosts/HOSTNAME/
  configuration.nix       # imports: session + features, plus host-only hardware tweaks
  home.nix                # imports: home features for this host
  hardware-configuration.nix
modules/
  base.nix                # every host, headless too: nix, user, ssh, locale, bootloader, tailscale
  graphical/
    default.nix           # role for hosts with a screen: audio, network, input method, fonts, sunshine
    niri.nix              # session: niri (laptops, desktops)
    bigscreen.nix         # session: Plasma Bigscreen (TV)
  features/               # opt-in: daed, gaming, virtualisation, waterloo-vpn, waydroid, work
  home/                   # home-manager, mirroring the tree above
    base.nix              #   registered by modules/base.nix
    graphical/            #   registered by the matching modules/graphical/*.nix
    features/             #   picked in each host's home.nix: apps, dev, retro-gaming, syncthing
dotfiles/                 # raw config files, one folder per app (niri/, rime/)
patches/
```

System modules register their home-manager counterparts through
`home-manager.sharedModules`, so picking a session also sets up its user config.

## 🔧 Customization Guide

### Adding a New Package

- **Every host**: `modules/base.nix` (system) or `modules/home/base.nix` (user)
- **Hosts with a screen**: `modules/graphical/default.nix` or `modules/home/graphical/default.nix`
- **One capability**: the matching module in `modules/features/` or `modules/home/features/`
- **One host**: `hosts/HOSTNAME/configuration.nix` or `hosts/HOSTNAME/home.nix`

### Adding a New Host

1. Create `hosts/NEWHOSTNAME/` with `configuration.nix`, `home.nix` and
   `hardware-configuration.nix`. In `configuration.nix`, import a session and the features:
   ```nix
   imports = [
     ./hardware-configuration.nix
     ../../modules/graphical/niri.nix
     ../../modules/features/daed.nix
   ];
   ```

2. Add the hostname to the list in `flake.nix`. The hostname and timezone are set for you.
   For a host installed from a different release, add it separately:
   ```nix
   // {NEWHOSTNAME = mkNixOS { hostname = "NEWHOSTNAME"; stateVersion = "26.11"; };}
   ```

### Adding a New Module

Put a service's firewall ports, user groups and trusted interfaces in the module that
enables the service, not in a shared file. Then import the module from the hosts that
need it (features), or from a role/session module if every such host needs it.

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## 🎯 Design Principles

1. **Config lives next to what needs it**: ports, groups and kernel modules sit in the module that enables the service
2. **Hosts compose, modules don't assume**: base → role → session, plus opt-in features; a host gets exactly what it imports
3. **Separation of Concerns**: System config separate from user config, in mirrored trees
4. **Variables over Literals**: Use `vars` for all personal information

## 🔐 Security Notes

- SSH is key-only (keys listed in `vars.sshKeys`); password and root login disabled
- Firewall enabled
- Trusted users configured for Nix daemon

## 📝 License

This configuration is provided as-is for personal use. Modify as needed for your setup.
