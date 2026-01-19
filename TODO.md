# Configuration tasks

Keep a service's firewall ports, user groups and kernel modules in the module that
enables the service, not in a shared block. Each host should get only what its
imports require. This also allows a server configuration without desktop services.

## Rollout

- [ ] Switch every host and confirm SSH login still works.
- [ ] On g16, after switching to `powerManagement.finegrained = true`, check that
      `cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` returns `suspended`
      when the discrete GPU is idle. Confirm that `nvidia-offload <app>` still works.

## Host-specific fixes

- [ ] Fix sound on matebook-14s in `hosts/matebook-14s/configuration.nix`.
  - [ ] Remove the `pacmd` line. PipeWire does not provide it, and it is not on the service's PATH.
  - [ ] Replace the 0.3-second polling loop with `alsactl monitor` if the jack control emits events.

## Servers

- [ ] Create `modules/headless.nix`. Import `base.nix` and use systemd-networkd instead of NetworkManager.
- [ ] Set `security.sudo.wheelNeedsPassword = true` in `headless.nix`. The setting in `base.nix` uses `lib.mkDefault`.
- [ ] Store Tailscale auth keys and service credentials with `sops-nix` or `agenix`.
- [ ] Start remote deployments with `nixos-rebuild --target-host`. Use `deploy-rs` or `colmena` for deployments with rollback support.
- [ ] Use `disko` to define partitions for new machines.
