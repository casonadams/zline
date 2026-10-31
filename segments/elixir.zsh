zline_segment_elixir() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "elixir"; then
    ver="$REPLY"
  elif [[ -f "mix.exs" || -f "mix.lock" ]]; then
    ver="ex"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 5 5 15 "ex:" $'\uE62D '
}
