zline_segment_deno() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "deno"; then
    ver="$REPLY"
  elif [[ -f "deno.json" || -f "deno.jsonc" || -f "deno.lock" ]]; then
    ver="deno"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 10 10 0 "deno:" $'\uE628 '
}
