# Hotfixes

Review after updating `flake.lock`. Remove each workaround only after the pinned
package includes the fix and testing succeeds on the affected host.

## Package fixes

| Package | Location | Workaround / removal condition | Upstream |
| --- | --- | --- | --- |
| AnyDesk | `modules/home/features/apps.nix` | Split patchelf calls to avoid binary corruption. Restore plain `anydesk` once fixed. | [nixpkgs #581673](https://github.com/NixOS/nixpkgs/pull/581673) |
| Sunshine | `modules/features/sunshine.nix` | Add NVIDIA driver RUNPATH. Remove package override when stock Sunshine supports NVENC correctly. | Not recorded |
| librime | `modules/graphical/default.nix`, `patches/rime-fix-input.patch` | Fix printable key-release handling during composition. Remove overlay and patch when stock Rime input works correctly. | Not recorded |

## Hardware workarounds

| Host | Location | Remove when |
| --- | --- | --- |
| MateBook 14s | `hosts/matebook-14s/configuration.nix`: `huawei-sound-fix` service | Stock audio stack switches speakers/headphones correctly, including after suspend. [Workaround reference](https://github.com/Smoren/huawei-ubuntu-sound-fix). |
| G16 | `hosts/g16/configuration.nix`: backlight kernel parameters | Brightness works with default Intel/NVIDIA driver settings, including after suspend. |

## Compatibility overrides to review

Not confirmed as temporary upstream bugs.

| Override | Location | Remove when |
| --- | --- | --- |
| Hyprland XWayland drag rule | `dotfiles/hyprland/hyprland.lua`: `fix-xwayland-drags` | XWayland dragging works without the rule. This config is not wired into current host sessions. |
