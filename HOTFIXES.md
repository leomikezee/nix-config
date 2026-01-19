# Hotfixes

Review these workarounds after updating `flake.lock`. Remove a workaround only when
the pinned package includes the fix and tests pass on the affected host.

## Package fixes

| Package | Location | Workaround / removal condition | Upstream |
| --- | --- | --- | --- |
| AnyDesk | `modules/home/features/apps.nix` | Split patchelf calls to avoid binary corruption. Use the unmodified `anydesk` package once it includes the fix. | [nixpkgs #581673](https://github.com/NixOS/nixpkgs/pull/581673) |
| Mango | `modules/graphical/mango.nix`, `patches/mango-wheel-shortcuts-inhibit.patch` | Honor shortcut inhibitors for wheel bindings so lan-mouse can forward modifier+wheel events. Remove the patch once nixpkgs includes the fix and sharing works on wheat-pc. | [mango #1623](https://github.com/mangowm/mango/pull/1623) |
| Mangobar | `modules/home/graphical/mango.nix`, `patches/mangobar-workspace-app-icons.patch` | Add workspace application icons and the GLib build dependency. Remove the patch and dependency override when the pinned Mangobar input includes the icons and they work on wheat-pc. | [mangobar #50](https://github.com/mangowm/mangobar/issues/50) |
| Sunshine | `modules/features/sunshine.nix` | Add NVIDIA driver RUNPATH. Remove package override when stock Sunshine supports NVENC correctly. | Not recorded |
| librime | `modules/graphical/default.nix`, `patches/rime-fix-input.patch` | Fix printable key-release handling during composition. Remove overlay and patch when stock Rime input works correctly. | Not recorded |

## Hardware workarounds

| Host | Location | Remove when |
| --- | --- | --- |
| MateBook 14s | `hosts/matebook-14s/configuration.nix`: `huawei-sound-fix` service | Stock audio stack switches speakers/headphones correctly, including after suspend. [Workaround reference](https://github.com/Smoren/huawei-ubuntu-sound-fix). |
| G16 | `hosts/g16/configuration.nix`: backlight kernel parameters | Brightness works with default Intel/NVIDIA driver settings, including after suspend. |
