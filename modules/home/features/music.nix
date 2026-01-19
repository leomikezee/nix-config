# modules/features/music.nix registers this NetEase launcher configuration.
{
  lib,
  pkgs,
  ...
}: let
  proxy = "http://127.0.0.1:18080";
  certificateBundle = "/var/lib/unm/ca-bundle.pem";

  proxiedYtDlp = pkgs.writeShellApplication {
    name = "yt-dlp";
    text = ''
      exec ${lib.getExe pkgs.yt-dlp} \
        --proxy ${lib.escapeShellArg proxy} \
        --compat-options no-certifi \
        "$@"
    '';
  };

  # Patch the cached package's launcher without changing its compiled binary.
  # Fail if Nixpkgs changes how the launcher references yt-dlp.
  cliamp =
    pkgs.runCommand "cliamp-unm-backend" {
      meta.mainProgram = "cliamp";
    } ''
      mkdir -p "$out/bin"
      substitute ${lib.getExe pkgs.cliamp} "$out/bin/cliamp" \
        --replace-fail \
          "${lib.getBin pkgs.yt-dlp}/bin" \
          "${lib.getBin proxiedYtDlp}/bin"
      chmod +x "$out/bin/cliamp"
    '';

  cliampUnm = pkgs.writeShellApplication {
    name = "cliamp-unm";
    text = ''
      if [ ! -r ${lib.escapeShellArg certificateBundle} ]; then
        echo 'UNM certificate bundle is missing; start unm.service first.' >&2
        exit 1
      fi

      export HTTP_PROXY=${lib.escapeShellArg proxy}
      export HTTPS_PROXY="$HTTP_PROXY"
      export ALL_PROXY="$HTTP_PROXY"
      export http_proxy="$HTTP_PROXY"
      export https_proxy="$HTTP_PROXY"
      export all_proxy="$HTTP_PROXY"
      export NO_PROXY='localhost,127.0.0.1,::1'
      export no_proxy="$NO_PROXY"
      export SSL_CERT_FILE=${lib.escapeShellArg certificateBundle}
      export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"

      # yt-dlp picks the Chrome keyring from the desktop name. Compositors such as
      # Mango and Niri fall back to a plaintext keyring and cannot decrypt cookies
      # stored in GNOME Keyring. Leave GNOME and KDE sessions alone.
      case ":''${XDG_CURRENT_DESKTOP:-}:" in
        *:GNOME:* | *:KDE:* | *:Unity:* | *:X-Cinnamon:*) ;;
        *) export XDG_CURRENT_DESKTOP=GNOME ;;
      esac

      exec ${lib.getExe cliamp} "$@"
    '';
  };
in {
  # The regular cliamp and yt-dlp commands remain unchanged.
  home.packages = [
    cliampUnm
    pkgs.cliamp
  ];
}
