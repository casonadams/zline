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
  _zline_segment_finish 2 2 0 "node:" $'\uE718 '
}
