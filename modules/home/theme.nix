{
  config,
  pkgs,
  vars,
  ...
}: {
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "blue";
    flavor = "mocha";
  };
}
