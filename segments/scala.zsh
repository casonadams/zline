zline_segment_scala() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "scala"; then
    ver="$REPLY"
  elif [[ -f "build.sbt" || -d ".scala-build" ]]; then
    ver="scala"
  else
    local -a sbt_files=( *.sbt(N) )
    if (( ${#sbt_files} > 0 )); then
      ver="scala"
    fi
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 9 9 15 "scala:" $'\uE737 '
}
