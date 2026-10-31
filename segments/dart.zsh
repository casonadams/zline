zline_segment_dart() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "dart" || _zline_read_tool_version "flutter"; then
    ver="$REPLY"
  elif [[ -f "pubspec.yaml" || -f "pubspec.lock" ]]; then
    ver="dart"
  fi

  _zline_segment_emit "$ver" 12 12 0 "dart:" $'\uE798 '
}
