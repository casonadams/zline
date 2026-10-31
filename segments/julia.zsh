zline_segment_julia() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "julia"; then
    ver="$REPLY"
  elif [[ -f "Project.toml" || -f "JuliaProject.toml" ]]; then
    ver="jl"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 13 13 15 "jl:" $'\uE624 '
}
