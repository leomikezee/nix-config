# Nix configuration

This repository configures NixOS hosts with flakes and home-manager.

## Usage

### Initial setup

1. Clone this repository:
   ```bash
   git clone <your-repo> ~/.config/nix-config
   cd ~/.config/nix-config
   ```

2. Generate hardware configuration:
   ```bash
   mkdir -p hosts/HOSTNAME
   nixos-generate-config --show-hardware-config > hosts/HOSTNAME/hardware-configuration.nix
   # Or
   cp /etc/nixos/hardware-configuration.nix hosts/HOSTNAME/
   ```

3. Enable flakes and Nix commands, then install Git and Vim:
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
   - `stateVersion` defaults to `"26.05"` in `mkNixOS`. Override it for hosts installed from another release
   - Adjust packages in module files
   - Configure host-specific settings
   - If you clone elsewhere, update `programs.nh.flake` in `modules/base.nix` and the nixd expression in `modules/home/base.nix`

### Build and activate

```bash
# Format the files, then run formatting, deadnix, statix and host evaluation checks
nix fmt .
nix flake check

# Update inputs when desired
nix flake update

# Build, show changes and activate. nh requests sudo when needed
nh os switch .
# or
nh os switch . -H HOSTNAME
# Use nixos-rebuild if nh is unavailable, such as on the first install
sudo nixos-rebuild switch --flake .#HOSTNAME
```

`nh clean` removes generations older than seven days each week. It keeps the current
generation.

Track new files with `git add` before validating them. Nix flakes cannot see
untracked files.

See [HOTFIXES.md](HOTFIXES.md) for temporary upstream fixes, hardware workarounds,
and their removal conditions. Review it after updating inputs.

## Layout

Each host imports one session and the features it needs. The session imports the
shared desktop configuration, which imports the base configuration.

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
    bigscreen.nix         # Plasma Bigscreen session for TVs
  features/               # dae, gaming, lan-mouse, miniserve via base, music, obs, retro-gaming, sunshine, virtualisation, waydroid, work
  home/                   # home-manager: base, graphical sessions, and user features
    base.nix              #   registered by modules/base.nix
    graphical/            #   registered by the matching modules/graphical/*.nix
    features/             #   gaming, lan-mouse, miniserve, music, retro-gaming, virtualisation, work: registered by the matching system feature
                          #   apps, claude-vpn, dev: imported from host home.nix files
dotfiles/                 # app configs: fastfetch, mango, mangobar, niri, rime, etc.
patches/
```

System modules register any required home-manager modules through
`home-manager.sharedModules`. Hosts import user-only features from `home.nix`.
A feature can have system configuration, user configuration or both.
It does not need a file in both module directories.

## Add a host

1. Create `hosts/NEWHOSTNAME/` with `configuration.nix`, `home.nix` and
   `hardware-configuration.nix`. In `configuration.nix`, import a session and the features:
   ```nix
   imports = [
     ../../modules/features/dae.nix
     ../../modules/graphical/niri.nix
     ./hardware-configuration.nix
   ];
   ```

2. Add the hostname to the list in `flake.nix`. `mkNixOS` sets `networking.hostName`.
   `modules/base.nix` uses `lib.mkDefault` to set the timezone to `America/Toronto`.
   For a host installed from a different release, add it separately:
   ```nix
   // {NEWHOSTNAME = mkNixOS { hostname = "NEWHOSTNAME"; stateVersion = "26.11"; };}
   ```

## Contributing

See [AGENTS.md](AGENTS.md) for contributor and agent guidelines covering Nix style,
module and package placement, and validation.

## Security notes

- SSH accepts only the keys in `vars.sshKeys`. Password and root login are disabled.
- The nftables firewall is enabled. Each module opens only its own ports.
- Members of `wheel` can use sudo without a password. A host can override this
  `lib.mkDefault` setting.
- The Nix daemon trusts the configured user.
