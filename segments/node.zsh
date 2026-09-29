zline_segment_node() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_find_up ".node-version"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_find_up ".nvmrc"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif [[ -n "$NODE_VERSION" ]]; then
    ver="$NODE_VERSION"
  elif _zline_read_tool_version "nodejs" || _zline_read_tool_version "node"; then
    ver="$REPLY"
  elif _zline_find_up "package.json"; then
    ver="node"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-2}"
  _zline_ret_bg="${opts[--bg]:-2}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="node:"
  else
    _zline_ret_icon=$'\uE718 '
  fi
}
