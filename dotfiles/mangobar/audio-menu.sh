#!/usr/bin/env bash
set -euo pipefail

# Optional: also move streams using the previous default, including recordings.
move_streams=false
case "${1:-}" in
  --move-existing-streams) move_streams=true ;;
  "") ;;
  *) printf 'Usage: %s [--move-existing-streams]\n' "$0" >&2; exit 2 ;;
esac

sinks=$(pactl --format=json list sinks)
sources=$(pactl --format=json list sources)
# A server may have devices in only one direction.
default_sink=$(pactl get-default-sink || true)
default_source=$(pactl get-default-source || true)

devices=$(jq -n --argjson sinks "$sinks" --argjson sources "$sources" '
  [
    ($sinks[] | . + {kind: "output"}),
    ($sources[] | select(
      (.monitor_source // "") == "" and
      .properties["device.class"] != "monitor"
    ) | . + {kind: "input"})
  ]
')
[[ $(jq 'length' <<<"$devices") -gt 0 ]] || exit 0

# One menu, outputs first. Use row indices: names/descriptions may overlap.
index=$(jq -r --arg sink "$default_sink" --arg source "$default_source" '
  .[] |
  (if .kind == "output" then
    (if .name == $sink then "● " else "○ " end) + "󰓃 Output · "
  else
    (if .name == $source then "● " else "○ " end) + "󰍬 Input  · "
  end) +
  ((.description // .name) | gsub("[\r\n\t]"; " "))
' <<<"$devices" | fuzzel --dmenu --index --prompt='Audio device') || exit 0
[[ "$index" =~ ^[0-9]+$ ]] || exit 0

name=$(jq -er --argjson index "$index" '.[$index].name' <<<"$devices") || exit 0
kind=$(jq -er --argjson index "$index" '.[$index].kind' <<<"$devices") || exit 0
case "$kind" in
  output)
    previous=$default_sink
    set_default=set-default-sink
    streams=sink-inputs
    move_stream=move-sink-input
    device_field=sink
    ;;
  input)
    previous=$default_source
    set_default=set-default-source
    streams=source-outputs
    move_stream=move-source-output
    device_field=source
    ;;
  *) exit 0 ;;
esac
[[ "$name" != "$previous" ]] || exit 0

# Only migrate after the server confirms the default change.
pactl "$set_default" "$name"
if "$move_streams"; then
  # Match the direction as well as the name. Monitor defaults are not listed,
  # so their recordings stay put when switching to a microphone.
  old_index=$(jq -r --arg name "$previous" --arg kind "$kind" '
    .[] | select(.kind == $kind and .name == $name) | .index
  ' <<<"$devices")
  if [[ -n "$old_index" ]]; then
    stream_list=$(pactl --format=json list "$streams")
    stream_ids=$(jq -r --arg field "$device_field" --argjson old "$old_index" '
      .[] | select(.[$field] == $old) | .index
    ' <<<"$stream_list")
    while IFS= read -r stream; do
      [[ -n "$stream" ]] || continue
      # Streams can disappear between enumeration and moving; keep going.
      if ! pactl "$move_stream" "$stream" "$name"; then
        printf 'Could not move audio stream %s to %s\n' "$stream" "$name" >&2
      fi
    done <<<"$stream_ids"
  fi
fi
