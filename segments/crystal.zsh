zline_segment_crystal() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "crystal"; then
    ver="$REPLY"
  elif [[ -f "shard.yml" || -f "shard.lock" ]]; then
    ver="cr"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 15 15 0 "cr:" $'\uE62F '
}
