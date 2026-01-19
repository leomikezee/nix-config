# Scoped NetEase launcher. Registered by modules/features/music.nix.
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

  # Patch only the cached package's launcher, retaining its compiled binary.
  # Fail explicitly if Nixpkgs stops referencing yt-dlp this way.
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

      exec ${lib.getExe cliamp} "$@"
    '';
  };
in {
  # The regular cliamp and yt-dlp commands remain unchanged.
  home.packages = [cliampUnm];
}
