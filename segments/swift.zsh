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
  _zline_ret_fg="${opts[--color]:-9}"
  _zline_ret_bg="${opts[--bg]:-9}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="swift:"
  else
    _zline_ret_icon=$'\uE755 '
  fi
}
