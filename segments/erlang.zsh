zline_segment_erlang() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_find_up ".erlang-version"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "erlang"; then
    ver="$REPLY"
  elif _zline_find_up "rebar.config" "erlang.mk"; then
    ver="erl"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 9 9 15 "erl:" $'\uE7B1 '
}
