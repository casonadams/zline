zline_segment_lua() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".lua-version" ]]; then
    read -r ver < ".lua-version" 2>/dev/null
  elif _zline_read_tool_version "lua"; then
    ver="$REPLY"
  elif [[ -f "init.lua" || -f "main.lua" ]]; then
    ver="lua"
  else
    local rocks=( *.rockspec(N) )
    if (( ${#rocks} > 0 )); then
      ver="lua"
    fi
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 4 4 15 "lua:" $'\uE620 '
}
