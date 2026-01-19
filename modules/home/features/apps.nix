# Desktop applications for laptops and desktops.
{pkgs, ...}: {
  xdg.configFile."imv/config".text = ''
    [binds]
    <Ctrl+r> = rotate by 90
  '';

  home.packages = with pkgs; [
    anydesk
    celluloid
    deskflow
    godot
    google-chrome
    imv
    obsidian
    rapidraw
    remmina
    vesktop
    vscode
    wechat
  ];

  xdg.desktopEntries.wechat = {
    name = "WeChat";
    exec = "${pkgs.coreutils}/bin/env XIM=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx ${pkgs.wechat}/bin/wechat %U";
    icon = "${pkgs.wechat}/share/icons/hicolor/256x256/apps/wechat.png";
    terminal = false;
    type = "Application";
  };
}
