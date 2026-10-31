zline_segment_zig() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".zigversion" ]]; then
    read -r ver < ".zigversion" 2>/dev/null
  elif _zline_read_tool_version "zig"; then
    ver="$REPLY"
  elif [[ -f "build.zig" || -f "build.zig.zon" ]]; then
    ver="zig"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 3 3 0 "zig:" $'\u21AF '
}
