# Nix Configuration

A modular, multi-host NixOS configuration using Flakes and home-manager.

## Usage

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
   nix.settings.experimental-features = ["flakes" "nix-command"];
   environment.systemPackages = with pkgs; [
     git
     vim
   ];
   ```

4. Review and customize:
   - Update `vars` in `flake.nix` with your information
   - `stateVersion` defaults to `"26.05"` in `mkNixOS`; override it for hosts installed from another release
   - Adjust packages in module files
   - Configure host-specific settings
   - If you clone elsewhere, update `programs.nh.flake` in `modules/base.nix` and the nixd expression in `modules/home/base.nix`

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
nh os switch . -H HOSTNAME
# Without nh (e.g. on first install):
sudo nixos-rebuild switch --flake .#HOSTNAME
```

Old generations are cleaned weekly by `nh clean` (older than 7 days; the current one is kept).

New files must be tracked by git (`git add`) before Nix can see them.

See [HOTFIXES.md](HOTFIXES.md) for temporary upstream fixes, hardware workarounds,
and their removal conditions. Review it after updating inputs.

## Layout

Each host imports one session (which pulls in the shared desktop config and the base),
plus any number of features.

```
flake.nix                 # inputs, vars, mkNixOS, host list
hosts/HOSTNAME/
  configuration.nix       # imports: session + features, plus host-only hardware tweaks
  home.nix                # imports: home features for this host
  hardware-configuration.nix
modules/
  base.nix                # every host, headless too: nix, user, ssh, locale, bootloader, tailscale, CLI tools
  graphical/
    default.nix           # shared desktop: audio, network, input method, fonts
    mango.nix             # session: mango
    niri.nix              # session: niri
    umbriel.nix           # session: umbriel
    bigscreen.nix         # session: Plasma Bigscreen (TV)
  features/               # apps, dae, dev, gaming, miniserve (via base), music, retro-gaming, sunshine, virtualisation, waterloo-vpn, waydroid, work
  home/                   # home-manager, mirroring the tree above
    base.nix              #   registered by modules/base.nix
    graphical/            #   registered by the matching modules/graphical/*.nix
    features/             #   apps, dev, gaming, miniserve, music, retro-gaming, virtualisation, work: registered by the matching system feature
                          #   claude-vpn, syncthing: imported in each host's home.nix
dotfiles/                 # app configs: fastfetch, mango, mangobar, niri, rime, etc.
patches/
```

System modules register their home-manager counterparts through
`home-manager.sharedModules`, so picking a session or feature also sets up its user config.

## Adding a New Host

1. Create `hosts/NEWHOSTNAME/` with `configuration.nix`, `home.nix` and
   `hardware-configuration.nix`. In `configuration.nix`, import a session and the features:
   ```nix
   imports = [
     ../../modules/features/dae.nix
     ../../modules/graphical/niri.nix
     ./hardware-configuration.nix
   ];
   ```

2. Add the hostname to the list in `flake.nix`; `mkNixOS` sets `networking.hostName`.
   The timezone defaults to `America/Toronto` (`lib.mkDefault` in `modules/base.nix`).
   For a host installed from a different release, add it separately:
   ```nix
   // {NEWHOSTNAME = mkNixOS { hostname = "NEWHOSTNAME"; stateVersion = "26.11"; };}
   ```

## Contributing

See [AGENTS.md](AGENTS.md) for contributor and agent guidelines covering Nix style,
module and package placement, and validation.

## Security Notes

- SSH is key-only (keys listed in `vars.sshKeys`); password and root login disabled
- Firewall enabled (nftables); each module opens only its own ports
- Passwordless sudo for `wheel` (`lib.mkDefault`, so a host can override it)
- Trusted users configured for Nix daemon
