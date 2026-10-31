zline_segment_node() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$ver" 2 2 0 "node:" $'\uE718 '
}
