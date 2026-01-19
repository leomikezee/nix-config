# Claude and headless Godot in Podman, with Tailscale exit-node routing.
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-vpn;
  godot = pkgs.godot_4;
  tools = pkgs.buildEnv {
    name = "claude-vpn-tools";
    paths = with pkgs; [
      bashInteractive
      cacert
      claude-code
      coreutils
      curl
      git
      godot
      iproute2
      nftables
      tailscale
      tini
      util-linux
    ];
    pathsToLink = ["/bin" "/etc/ssl/certs"];
  };
  resolvConf = pkgs.writeText "claude-vpn-resolv.conf" ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
  '';
  firewall = pkgs.writeText "claude-vpn-firewall.nft" ''
    table inet claude_vpn {
      chain output {
        type filter hook output priority -10; policy drop;
        oifname "lo" accept
        # Allow tailscaled to reach the underlying network.
        meta skuid 0 accept
        # Block direct tailnet traffic.
        ip daddr 100.64.0.0/10 counter reject with icmpx type admin-prohibited
        ip6 daddr fd7a:115c:a1e0::/48 counter reject with icmpx type admin-prohibited
        oifname "tailscale0" accept
        counter reject with icmpx type admin-prohibited
      }
    }
  '';
  runCommand = pkgs.writeShellScript "claude-vpn-command" ''
    set -euo pipefail
    export PATH=${tools}/bin
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export GIT_SSL_CAINFO="$SSL_CERT_FILE"
    export HOME=/home/claude USER=claude LOGNAME=claude
    cd /workspace
    exec setpriv \
      --reuid="$CLAUDE_UID" --regid="$CLAUDE_GID" --clear-groups \
      --bounding-set=-all --inh-caps=-all --ambient-caps=-all \
      --no-new-privs -- "$@"
  '';
  entrypoint = pkgs.writeShellScript "claude-vpn-entrypoint" ''
    set -euo pipefail
    export PATH=${tools}/bin
    rm -f /run/claude-vpn-ready

    printf 'root:x:0:0:root:/root:/bin/bash\nclaude:x:%s:%s:Claude:/home/claude:/bin/bash\n' \
      "$CLAUDE_UID" "$CLAUDE_GID" > /etc/passwd
    printf 'root:x:0:\nclaude:x:%s:\n' "$CLAUDE_GID" > /etc/group
    mkdir -p /run/tailscale /var/lib/tailscale
    chmod 700 /run/tailscale /var/lib/tailscale

    nft -f ${firewall}

    # Keep daemon output out of Claude's interactive terminal. The state volume
    # preserves the latest run's log for debugging, without growing indefinitely.
    tailscale_log=/var/lib/tailscale/tailscaled.log
    tailscaled \
      --state=/var/lib/tailscale/tailscaled.state \
      --socket=/run/tailscale/tailscaled.sock \
      --tun=tailscale0 > "$tailscale_log" 2>&1 &
    tailscale_pid=$!

    for ((attempt = 0; attempt < 100; attempt++)); do
      [[ -S /run/tailscale/tailscaled.sock ]] && break
      if ! kill -0 "$tailscale_pid" 2>/dev/null; then
        echo 'tailscaled exited during startup.' >&2
        tail -n 50 "$tailscale_log" >&2
        exit 1
      fi
      sleep 0.1
    done
    if [[ ! -S /run/tailscale/tailscaled.sock ]]; then
      echo 'Timed out waiting for tailscaled to start.' >&2
      tail -n 50 "$tailscale_log" >&2
      exit 1
    fi
    # Exit-node names require a peer list, which is unavailable before login.
    # Clear any saved exit node while connecting; the firewall blocks direct
    # traffic from the unprivileged user, and no user command runs yet.
    tailscale --socket=/run/tailscale/tailscaled.sock up \
      --hostname="claude-vpn-$CLAUDE_UID" \
      --exit-node= \
      --exit-node-allow-lan-access=false \
      --accept-routes=false \
      --accept-dns=false \
      --timeout=120s
    # The peer list can lag behind login, especially on a fresh daemon.
    for ((attempt = 0; attempt < 30; attempt++)); do
      if tailscale --socket=/run/tailscale/tailscaled.sock set \
        --exit-node="$CLAUDE_EXIT_NODE" \
        --exit-node-allow-lan-access=false 2>/run/exit-node-error; then
        break
      fi
      if ((attempt == 29)); then
        cat /run/exit-node-error >&2
        exit 1
      fi
      sleep 1
    done

    # Keep Podman's DNS until Tailscale is connected.
    cp ${resolvConf} /etc/resolv.conf
    test -x ${runCommand}
    touch /run/claude-vpn-ready
    # Keep the container alive between commands, but fail if tailscaled exits.
    wait "$tailscale_pid"
  '';
  image = pkgs.dockerTools.buildLayeredImage {
    name = "claude-vpn";
    contents = [tools];
    extraCommands = ''
      mkdir -p etc root home/claude workspace tmp run var/lib/tailscale usr
      ln -s ../bin usr/bin
      chmod 1777 tmp
    '';
    config = {
      Entrypoint = ["${pkgs.tini}/bin/tini" "-g" "--" entrypoint];
      WorkingDir = "/workspace";
      Env = ["DISABLE_AUTOUPDATER=1" "PATH=${tools}/bin"];
    };
  };
  launcher = pkgs.writeShellApplication {
    name = "claude-vpn";
    runtimeInputs = [
      osConfig.virtualisation.podman.package
      pkgs.coreutils
      pkgs.util-linux
    ];
    text = ''
      exit_node=${lib.escapeShellArg cfg.exitNode}
      exit_node="''${CLAUDE_VPN_EXIT_NODE:-$exit_node}"
      action='exec'
      while [[ "$#" -gt 0 ]]; do
        case "$1" in
          --exit-node=*) exit_node="''${1#*=}"; shift ;;
          start|stop|status|restart)
            if [[ "$action" != exec ]]; then
              echo 'Specify only one lifecycle subcommand.' >&2
              exit 1
            fi
            action="$1"; shift
            ;;
          --help)
            echo 'Usage: claude-vpn [--exit-node=NAME_OR_IP] [--] [CLAUDE_ARGS...]'
            echo '       claude-vpn [--exit-node=NAME_OR_IP] --run COMMAND [ARGS...]'
            echo '       claude-vpn {start|stop|status|restart} [--exit-node=NAME_OR_IP]'
            echo 'Commands auto-start and reuse one container for the current project.'
            echo 'stop removes the container, preserving Claude home and Tailscale state.'
            echo 'Use restart to change the project, exit node, or container image.'
            echo 'Use CLAUDE_VPN_EXIT_NODE or programs.claude-vpn.exitNode for a default.'
            echo 'Use -- to pass a reserved subcommand name to Claude.'
            exit 0
            ;;
          *) break ;;
        esac
      done
      command=(${pkgs.claude-code}/bin/claude)
      if [[ "$action" != exec && "$#" -gt 0 ]]; then
        echo "Unexpected arguments for $action." >&2
        exit 1
      fi
      if [[ "''${1:-}" == --run ]]; then
        shift
        if [[ "$#" == 0 ]]; then
          echo '--run requires a command.' >&2
          exit 1
        fi
        command=()
      elif [[ "''${1:-}" == -- ]]; then
        shift
      fi
      tty_flags=(-i)
      if [[ -t 0 && -t 1 ]]; then
        tty_flags+=(-t)
      fi
      uid=$(id -u)
      gid=$(id -g)
      if [[ "$uid" == 0 || "$gid" == 0 ]]; then
        echo 'Run claude-vpn as your regular user, not with sudo.' >&2
        exit 1
      fi

      state="''${XDG_STATE_HOME:-$HOME/.local/state}/claude-vpn"
      mkdir -p "$state/home"
      chmod 700 "$state" "$state/home"

      # Serialize lifecycle operations, not the interactive commands themselves.
      exec 9>"$state/lifecycle.lock"
      flock 9
      sudo -v
      name="claude-vpn-$uid"
      image_ref=${lib.escapeShellArg "${image.imageName}:${image.imageTag}"}
      exists=false
      if sudo podman container exists "$name"; then
        exists=true
      fi
      if [[ "$action" == status ]]; then
        if [[ "$exists" == false ]]; then
          echo 'claude-vpn is stopped (no container).'
        else
          sudo podman inspect --format 'State: {{.State.Status}}{{"\n"}}Workspace: {{index .Config.Labels "claude-vpn.workspace"}}{{"\n"}}Exit node: {{index .Config.Labels "claude-vpn.exit-node"}}' "$name"
          if sudo podman exec "$name" test -f /run/claude-vpn-ready 2>/dev/null; then
            echo 'VPN initialization: complete'
          else
            echo 'VPN initialization: incomplete (see sudo podman logs '"$name"')'
          fi
        fi
        exit 0
      fi
      if [[ "$action" == stop ]]; then
        if [[ "$exists" == true ]]; then
          sudo podman stop "$name" >/dev/null
          sudo podman rm "$name" >/dev/null
        fi
        echo 'claude-vpn stopped; persistent data retained.'
        exit 0
      fi

      workspace=$(pwd -P)
      if [[ "$workspace" == "$(realpath "$HOME")" || "$workspace" == / ]]; then
        echo 'Refusing to mount your home or root directory; cd into a project.' >&2
        exit 1
      fi
      if [[ "$exists" == true ]]; then
        saved_exit_node=$(sudo podman inspect --format '{{index .Config.Labels "claude-vpn.exit-node"}}' "$name")
        if [[ "$action" == restart ]]; then
          # Preserve the selected exit node when no new default was supplied.
          exit_node="''${exit_node:-$saved_exit_node}"
        else
          saved_workspace=$(sudo podman inspect --format '{{index .Config.Labels "claude-vpn.workspace"}}' "$name")
          if [[ "$saved_workspace" != "$workspace" ]]; then
            echo "Container workspace is $saved_workspace; use claude-vpn restart to switch projects." >&2
            exit 1
          fi
          if [[ -n "$exit_node" && "$exit_node" != "$saved_exit_node" ]]; then
            echo 'Exit node differs; use claude-vpn restart --exit-node=NAME_OR_IP.' >&2
            exit 1
          fi
          saved_image=$(sudo podman inspect --format '{{index .Config.Labels "claude-vpn.image"}}' "$name")
          if [[ "$saved_image" != "$image_ref" ]]; then
            echo 'Container image has changed; use claude-vpn restart.' >&2
            exit 1
          fi
        fi
      fi
      if [[ "$exists" == false || "$action" == restart ]]; then
        if [[ -z "$exit_node" || "$exit_node" == '<no value>' ]]; then
          echo 'Specify --exit-node=NAME_OR_IP or configure programs.claude-vpn.exitNode.' >&2
          exit 1
        fi
        if ! sudo podman image exists "$image_ref"; then
          sudo podman load --input ${image}
        fi
        if [[ "$exists" == true ]]; then
          sudo podman stop "$name" >/dev/null
          sudo podman rm "$name" >/dev/null
        fi
        sudo podman run --detach \
          --name "$name" \
          --hostname claude-vpn \
          --label "claude-vpn.workspace=$workspace" \
          --label "claude-vpn.exit-node=$exit_node" \
          --label "claude-vpn.image=$image_ref" \
          --tmpfs /run:rw,nosuid,nodev \
          --device /dev/net/tun \
          --cap-drop ALL \
          --cap-add NET_ADMIN \
          --cap-add SETUID \
          --cap-add SETGID \
          --cap-add SETPCAP \
          --security-opt no-new-privileges \
          --env "CLAUDE_UID=$uid" \
          --env "CLAUDE_GID=$gid" \
          --env "CLAUDE_EXIT_NODE=$exit_node" \
          --volume "claude-vpn-tailscale-$uid:/var/lib/tailscale" \
          --volume "$state/home:/home/claude" \
          --volume "$workspace:/workspace" \
          "$image_ref" >/dev/null
      elif [[ $(sudo podman inspect --format '{{.State.Running}}' "$name") != true ]]; then
        sudo podman start "$name" >/dev/null
      fi

      # Do not execute user commands until the firewall and exit node are ready.
      echo 'Waiting for claude-vpn; follow any Tailscale authentication URL below...' >&2
      # tailscale up prints the login URL to the container logs. Stream it now,
      # rather than hiding it until the authentication timeout has elapsed.
      sudo podman logs --follow --tail 50 "$name" >&2 &
      log_pid=$!
      stop_logs() {
        if [[ -n "$log_pid" ]]; then
          sudo kill "$log_pid" 2>/dev/null || true
          wait "$log_pid" 2>/dev/null || true
          log_pid=""
        fi
      }
      trap stop_logs EXIT
      trap 'exit 130' INT
      trap 'exit 143' TERM
      ready=false
      for ((attempt = 0; attempt < 180; attempt++)); do
        if [[ $(sudo podman inspect --format '{{.State.Running}}' "$name") != true ]]; then
          echo 'Container exited during VPN initialization.' >&2
          break
        fi
        if sudo podman exec "$name" test -f /run/claude-vpn-ready 2>/dev/null; then
          ready=true
          break
        fi
        sleep 1
      done
      stop_logs
      trap - EXIT INT TERM
      if [[ "$ready" != true ]]; then
        sudo podman logs --tail 50 "$name" >&2
        echo "VPN not ready. Check sudo podman logs $name; for daemon details:" >&2
        echo "sudo podman exec $name tail -n 50 /var/lib/tailscale/tailscaled.log" >&2
        echo 'For first-time login, follow the authentication URL in those logs.' >&2
        exit 1
      fi
      flock -u 9
      exec 9>&-
      if [[ "$action" != exec ]]; then
        echo "claude-vpn is ready for $workspace."
        exit 0
      fi
      exec sudo podman exec "''${tty_flags[@]}" "$name" ${runCommand} "''${command[@]}" "$@"
    '';
  };
in {
  options.programs.claude-vpn = {
    enable = lib.mkEnableOption "Claude and headless Godot behind a container-local Tailscale exit node";
    exitNode = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "my-exit-node";
      description = "Default Tailscale exit node name or IP. May also be supplied to claude-vpn at runtime.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [launcher];
  };
}
