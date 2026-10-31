zline_segment_crystal() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "crystal"; then
    ver="$REPLY"
  elif [[ -f "shard.yml" || -f "shard.lock" ]]; then
    ver="cr"
  fi

  _zline_segment_emit "$ver" 15 15 0 "cr:" $'\uE62F '
}
