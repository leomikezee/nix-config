# NetEase playback through a local UNM proxy; user tools live in home-manager.
{
  config,
  inputs,
  pkgs,
  ...
}: {
  home-manager.sharedModules = [../home/features/music.nix];

  systemd.services.unm = {
    description = "UnblockNeteaseMusic proxy";
    after = [
      "network-online.target"
      "unm-certificate.service"
    ];
    wants = ["network-online.target"];
    requires = ["unm-certificate.service"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [
      nodejs
      yt-dlp
    ];
    environment = {
      NODE_ENV = "production";
      SIGN_CERT = "/var/lib/unm/server.crt";
      SSL_CERT_FILE = config.security.pki.caBundle;
      XDG_CACHE_HOME = "/var/cache/unm";
    };
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = "server.key:/var/lib/unm/server.key";
      CacheDirectory = "unm";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
    script = ''
      export SIGN_KEY="$CREDENTIALS_DIRECTORY/server.key"
      # Both the HTTP proxy and HTTPS interception listener stay on loopback.
      # Use upstream's bundled JavaScript, pinned by flake.lock.
      exec ${pkgs.nodejs}/bin/node ${inputs.unm}/precompiled/app.js \
        -a 127.0.0.1 -p 18080:18081
    '';
  };

  systemd.services.unm-certificate = {
    description = "Create the local UnblockNeteaseMusic certificate and trust bundle";
    path = with pkgs; [
      coreutils
      openssl
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "unm";
      StateDirectoryMode = "0755";
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
    script = ''
      cd /var/lib/unm

      # Keep the private key out of the Nix store. Renew at boot when less than
      # 30 days remain; UNM starts only after this service finishes.
      if [ ! -s server.key ] || [ ! -s server.crt ] \
        || ! openssl x509 -checkend 2592000 -noout -in server.crt; then
        temporary=$(mktemp -d)
        trap 'rm -rf "$temporary"' EXIT
        openssl req -x509 -newkey rsa:2048 -noenc -days 3650 \
          -subj '/CN=Local UnblockNeteaseMusic' \
          -addext 'basicConstraints=critical,CA:TRUE' \
          -addext 'keyUsage=critical,digitalSignature,keyEncipherment,keyCertSign' \
          -addext 'extendedKeyUsage=serverAuth' \
          -addext 'subjectAltName=DNS:music.163.com,DNS:*.music.163.com,DNS:interface.music.163.com.163jiasu.com,DNS:interface3.music.163.com.163jiasu.com' \
          -keyout "$temporary/server.key" \
          -out "$temporary/server.crt"
        install -m 0600 "$temporary/server.key" server.key
        install -m 0644 "$temporary/server.crt" server.crt
      fi

      # Only cliamp-unm trusts this certificate, not the rest of the system.
      cat ${config.security.pki.caBundle} server.crt > ca-bundle.pem
      chmod 0644 ca-bundle.pem server.crt
    '';
  };
}
