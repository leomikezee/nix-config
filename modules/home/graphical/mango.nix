# Home config for the Mango session. Registered by modules/graphical/mango.nix.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.mangobar.homeManagerModules.default];

  home.packages = with pkgs; [
    fuzzel
    grim
    mako
    playerctl
    slurp
    sunsetr
    swaybg
    swaylock
  ];

  services.mangobar = {
    enable = true;
    systemdTarget = "mango-session.target";
    settings = {
      layer = "top";
      height = 24;
      buffer-scale = 1;
      sys-interval = 2;

      modules-left = [
        "workspaces"
        "window"
      ];
      modules-center = [
        "clock#date"
        "clock#time"
      ];
      modules-right = [
        "hideclients"
        "tray"
        "network"
        "cpu"
        "memory"
        "pulseaudio"
        "custom/power"
      ];

      workspaces = {
        hide-empty = true;
        overview-label = "OVERVIEW";
        on-click = "activate";
        on-click-right = "toggle";
      };
      window = {
        format = "{}";
        max-length = 500;
      };

      "clock#date".format = " {:L%b %d·%A}";
      "clock#time".format = " {:L%H:%M}";

      hideclients.format = " {}";
      tray = {
        icon-size = 24;
        spacing = 10;
      };
      network = {
        format = "{icon} {ifname}";
        format-wifi = "{signal} {ssid}";
        format-disconnected = "{icon}";
        icon-wifi = "󰖩";
        icon-ethernet = "󰈀";
        icon-disconnected = "󰖪";
        signal-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        format-alt = "↓{down} ↑{up}";
      };
      cpu.format = " {load}%";
      memory.format = " {}%";
      pulseaudio = {
        format = "{icon} {volume}% {bt}";
        format-muted = "󰝟 {volume}% {bt}";
        icons = ["󰝟" "󰕿" "󰕾"];
        on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
        on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
      };
      "custom/power" = {
        format = "⏻";
        on-click = "~/.config/mangobar/power-menu.sh";
      };
    };
  };

  xdg.configFile."mangobar/style.css".source = ../../../dotfiles/mangobar/style.css;
  xdg.configFile."mangobar/power-menu.sh" = {
    source = ../../../dotfiles/mangobar/power-menu.sh;
    executable = true;
  };
  xdg.configFile."mako/config".source = ../../../dotfiles/mako/config;
  xdg.configFile."mango/config.conf".source = ../../../dotfiles/mango/config.conf;
}
