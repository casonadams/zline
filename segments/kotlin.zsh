zline_segment_kotlin() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "kotlin"; then
    ver="$REPLY"
  elif [[ -f "build.gradle.kts" || -f "settings.gradle.kts" ]]; then
    ver="kt"
  else
    local -a kt_files=( *.kt(N) )
    if (( ${#kt_files} > 0 )); then
      ver="kt"
    fi
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 13 13 15 "kt:" $'\uF1219 '
}
