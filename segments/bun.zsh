zline_segment_bun() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "bun"; then
    ver="$REPLY"
  elif [[ -f "bun.lockb" || -f "bun.lock" || -f "bunfig.toml" ]]; then
    ver="bun"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 15 15 0 "bun:" $'\uE76F '
}
