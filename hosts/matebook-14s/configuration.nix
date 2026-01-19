{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop-enviroment.nix
    ../../modules/gaming.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  time.timeZone = "America/Toronto";

  networking.hostName = "matebook-14s";

  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0.75";
    };
  };

  systemd.services.huawei-sound-fix = {
    # https://github.com/Smoren/huawei-ubuntu-sound-fix
    enable = true;
    description = "Huawei Matebook Sound Fix Daemon";
    wantedBy = ["multi-user.target"];

    path = with pkgs; [
      alsa-tools
      alsa-utils
    ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "always";
      RestartSec = "3";
    };

    script = ''
      function move_output() {
         hda-verb /dev/snd/hwC0D0 0x16 0x701 "$@" > /dev/null 2> /dev/null
      }

      function move_output_to_speaker() {
          move_output 0x0001
      }

      function move_output_to_headphones() {
          move_output 0x0000
      }

      function switch_to_speaker() {
          move_output_to_speaker
          # enable speaker
          hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0002 > /dev/null 2> /dev/null
          # disable headphones
          hda-verb /dev/snd/hwC0D0 0x1 0x715 0x2 > /dev/null 2> /dev/null
      }

      function switch_to_headphones() {
          move_output_to_headphones
          # disable speaker
          hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0000 > /dev/null 2> /dev/null
          # pin output mode
          hda-verb /dev/snd/hwC0D0 0x1 0x717 0x2 > /dev/null 2> /dev/null
          # pin enable
          hda-verb /dev/snd/hwC0D0 0x1 0x716 0x2 > /dev/null 2> /dev/null
          # clear pin value
          hda-verb /dev/snd/hwC0D0 0x1 0x715 0x0 > /dev/null 2> /dev/null
          # Attempt to set pulseaudio sink (May fail as root, so we allow failure with || true)
          pacmd set-sink-port alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink "[Out] Headphones" || true
      }

      function get_sound_card_index() {
          cat /proc/asound/cards | grep sof-hda-dsp | head -n1 | grep -Eo "^\s*[0-9]+"
      }

      sleep 2

      card_index=$(get_sound_card_index)
      # remove leading whitespaces
      card_index="''${card_index#"''${card_index%%[![:space:]]*}"}"
      if [ -z "$card_index" ]; then
          echo "sof-hda-dsp card is not found in /proc/asound/cards"
          exit 1
      fi

      old_status=0

      while true; do
          # if headphone jack isn't plugged:
          if amixer "-c$card_index" get Headphone | grep -q "off"; then
              status=1
              move_output_to_speaker
          else
              status=2
              move_output_to_headphones
          fi

          if [ "$status" -ne "$old_status" ]; then
              case "$status" in
                  1)
                      echo "Headphones disconnected - Switching to Speakers"
                      switch_to_speaker
                      ;;
                  2)
                      echo "Headphones connected - Switching to Headphones"
                      switch_to_headphones
                      ;;
              esac
              old_status=$status
          fi

          sleep .3
      done
    '';
  };
}
