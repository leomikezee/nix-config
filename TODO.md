# Config TODO

**Guiding principle:** configuration lives next to the thing that needs it. A
service's firewall ports, user groups and kernel modules belong in the module that
enables that service, never in a shared "everything" block. Then a host gets
exactly what it imports, which also makes a lean server profile possible.

## Rollout

- [ ] Switch every host and confirm SSH login still works
- [ ] g16: after switching to `powerManagement.finegrained = true`, check that the dGPU powers off when idle
      (`cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` → `suspended`) and that
      `nvidia-offload <app>` still works

## Host-specific fixes

- [ ] **matebook-14s sound fix** (`hosts/matebook-14s/configuration.nix`)
  - [ ] Remove the `pacmd` line (doesn't exist under PipeWire and isn't on the service's PATH)
  - [ ] Replace the 0.3 s polling loop with `alsactl monitor`, if the jack control emits events

## Servers

- [ ] Create `modules/headless.nix` (imports `base.nix`; systemd-networkd instead of NetworkManager)
- [ ] `security.sudo.wheelNeedsPassword = true` in `headless.nix` (`base.nix` already uses `lib.mkDefault`)
- [ ] Secrets: `sops-nix` or `agenix` (Tailscale auth key, service credentials)
- [ ] Deploys: `nixos-rebuild --target-host` first; `deploy-rs`/`colmena` for rollback-safe deploys
- [ ] `disko` for declarative partitioning of new machines
