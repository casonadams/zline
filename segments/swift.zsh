zline_segment_swift() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".swift-version" ]]; then
    read -r ver < ".swift-version" 2>/dev/null
  elif _zline_read_tool_version "swift"; then
    ver="$REPLY"
  elif [[ -f "Package.swift" ]]; then
    ver="swift"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 9 9 15 "swift:" $'\uE755 '
}
