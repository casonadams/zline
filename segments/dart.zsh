zline_segment_dart() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "dart" || _zline_read_tool_version "flutter"; then
    ver="$REPLY"
  elif [[ -f "pubspec.yaml" || -f "pubspec.lock" ]]; then
    ver="dart"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 12 12 0 "dart:" $'\uE798 '
}
