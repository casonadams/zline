zline_segment_bun() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "bun"; then
    ver="$REPLY"
  elif [[ -f "bun.lockb" || -f "bun.lock" || -f "bunfig.toml" ]]; then
    ver="bun"
  fi

  _zline_segment_emit "$ver" 15 15 0 "bun:" $'\uE76F '
}
