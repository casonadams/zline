zline_segment_swift() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f ".swift-version" ]]; then
    read -r ver < ".swift-version" 2>/dev/null
  elif _zline_read_tool_version "swift"; then
    ver="$REPLY"
  elif [[ -f "Package.swift" ]]; then
    ver="swift"
  fi

  _zline_segment_emit "$ver" 9 9 15 "swift:" $'\uE755 '
}
