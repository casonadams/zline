zline_segment_bun() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "bun"; then
    ver="$REPLY"
  elif [[ -f "bun.lockb" || -f "bun.lock" || -f "bunfig.toml" ]]; then
    ver="bun"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-15}"
  _zline_ret_bg="${opts[--bg]:-15}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="bun:"
  else
    _zline_ret_icon=$'\uE76F '
  fi
}
