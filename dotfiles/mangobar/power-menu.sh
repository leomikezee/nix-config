#!/usr/bin/env bash
set -euo pipefail

choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nPower off\n' | fuzzel --dmenu --prompt='Power' || true)
case "$choice" in
  Lock) swaylock ;;
  Suspend) sudo systemctl suspend ;;
  'Log out') sudo loginctl terminate-user "$USER" ;;
  Reboot) sudo systemctl reboot ;;
  'Power off') sudo systemctl poweroff ;;
esac
