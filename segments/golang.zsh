zline_segment_golang() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_find_up "go.mod" "go.work"; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "go "* ]]; then
        ver="${line#go }"
        ver="${ver%$'\r'}"
        break
      fi
    done < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "golang" || _zline_read_tool_version "go"; then
    ver="$REPLY"
  fi

  _zline_segment_emit "$ver" 6 6 0 "go:" $'\uE627 '
}
