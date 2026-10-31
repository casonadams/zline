zline_segment_zig() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f ".zigversion" ]]; then
    read -r ver < ".zigversion" 2>/dev/null
  elif _zline_read_tool_version "zig"; then
    ver="$REPLY"
  elif [[ -f "build.zig" || -f "build.zig.zon" ]]; then
    ver="zig"
  fi

  _zline_segment_emit "$ver" 3 3 0 "zig:" $'\u21AF '
}
