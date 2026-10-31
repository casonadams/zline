zline_segment_rust() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_find_up "rust-toolchain"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_find_up "rust-toolchain.toml"; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == *"channel"* ]]; then
        ver="${line#*=}"
        ver="${ver//[[:space:]\"\']}"
        break
      fi
    done < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "rust"; then
    ver="$REPLY"
  elif _zline_find_up "Cargo.toml"; then
    ver="rust"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 1 1 15 "rs:" $'\uE7A8 '
}
