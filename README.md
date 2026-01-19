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
   cp /etc/nixos/hardware-configuration.nix > hosts/HOSTNAME/
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
   - Adjust packages in module files
   - Configure host-specific settings

### Building and Activating

```bash
# Format nix files
sudo nix fmt .

# Build and activate (requires sudo)
sudo nix flake update && sudo nixos-rebuild switch --flake .#HOSTNAME
```

## 🔧 Customization Guide

### Adding a New Package

**System-wide** (all users):
- Edit `modules/common.nix` or appropriate module
- Add package to `environment.systemPackages`

**User-specific** (home-manager):
- Edit appropriate module in `modules/home/`
- Add package to `home.packages`

**Host-specific**:
- Edit `hosts/HOSTNAME/configuration.nix` or `hosts/HOSTNAME/home.nix`

### Adding a New Host

1. Create host directory:
   ```bash
   mkdir -p hosts/NEWHOSTNAME
   ```

2. Create configuration files:
   - `hosts/NEWHOSTNAME/configuration.nix`
   - `hosts/NEWHOSTNAME/home.nix`
   - `hosts/NEWHOSTNAME/hardware-configuration.nix`

3. Add to `flake.nix`:
   ```nix
   nixosConfigurations.NEWHOSTNAME = mkNixOS {
     hostname = "NEWHOSTNAME";
     system = "x86_64-linux";  # or appropriate architecture
   };
   ```

### Adding a New Module

1. Create module file in `modules/`
2. Import in relevant host `configuration.nix`:
   ```nix
   imports = [
     ../../modules/your-new-module.nix
   ];
   ```

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## 🎯 Design Principles

1. **DRY (Don't Repeat Yourself)**: Shared configuration in modules, host-specific overrides in host files
2. **Separation of Concerns**: System config separate from user config
3. **Variables over Literals**: Use `vars` for all personal information
4. **Modularity**: Easy to add/remove features and hosts
5. **Clear Hierarchy**: modules → hosts → specific configurations

## 🔐 Security Notes

- SSH password authentication disabled on server
- Firewall enabled on server with minimal ports
- No root login via SSH
- Trusted users configured for Nix daemon

## 📝 License

This configuration is provided as-is for personal use. Modify as needed for your setup.
