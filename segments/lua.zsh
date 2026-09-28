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
  _zline_ret_fg="${opts[--color]:-4}"
  _zline_ret_bg="${opts[--bg]:-4}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="lua:"
  else
    _zline_ret_icon=$'\uE620 '
  fi
}
