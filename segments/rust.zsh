zline_segment_rust() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$ver" 1 1 15 "rs:" $'\uE7A8 '
}
