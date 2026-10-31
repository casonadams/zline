zline_segment_kotlin() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "kotlin"; then
    ver="$REPLY"
  elif [[ -f "build.gradle.kts" || -f "settings.gradle.kts" ]]; then
    ver="kt"
  else
    local -a kt_files=( *.kt(N) )
    if (( ${#kt_files} > 0 )); then
      ver="kt"
    fi
  fi

  _zline_segment_emit "$ver" 13 13 15 "kt:" $'\uF1219 '
}
