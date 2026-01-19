# Home config for hosts with a screen. Registered by modules/graphical/default.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    dotool
    libimobiledevice # iOS devices; pairs with services.usbmuxd
  ];

  services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
    x11.enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
      size = 14;
    };
    quickAccessTerminalConfig = {
      lines = 48;
      margin_left = 512;
      margin_right = 512;
    };
    settings = {
      disable_ligatures = "cursor";
    };
    shellIntegration.enableFishIntegration = true;
  };

  home.file."rime/default.custom.yaml".source = ../../../dotfiles/rime/default.custom.yaml;
}
