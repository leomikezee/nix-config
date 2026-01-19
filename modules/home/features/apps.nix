# User configuration for desktop apps. Registered by modules/features/apps.nix.
{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (anydesk.overrideAttrs (old: {
      # https://github.com/NixOS/nixpkgs/pull/581673
      # Patch RPATH before the interpreter to avoid corrupting this non-PIE binary.
      postFixup =
        lib.replaceStrings
        [
          ''
            patchelf \
              --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
              --set-rpath "${lib.makeLibraryPath old.buildInputs}" \
              $out/bin/anydesk
          ''
        ]
        [
          ''
            patchelf --set-rpath "${lib.makeLibraryPath old.buildInputs}" $out/bin/anydesk
            patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/bin/anydesk
          ''
        ]
        old.postFixup;
    }))
    authenticator
    celluloid
    deskflow
    godot
    google-chrome
    herdr-desktop
    obsidian
    rapidraw
    remmina
    vscode
    wechat
  ];

  programs.imv = {
    enable = true;
    settings.binds."<Ctrl+r>" = "rotate by 90";
  };
}
