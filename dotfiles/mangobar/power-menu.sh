#!/usr/bin/env bash
set -euo pipefail

choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nPower off\n' | fuzzel --dmenu --prompt='Power' || true)
case "$choice" in
  Lock) swaylock ;;
  Suspend) systemctl suspend ;;
  'Log out') loginctl terminate-user "$USER" ;;
  Reboot) systemctl reboot ;;
  'Power off') systemctl poweroff ;;
esac
