zline_segment_scala() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "scala"; then
    ver="$REPLY"
  elif [[ -f "build.sbt" || -d ".scala-build" ]]; then
    ver="scala"
  else
    local -a sbt_files=( *.sbt(N) )
    if (( ${#sbt_files} > 0 )); then
      ver="scala"
    fi
  fi

  _zline_segment_emit "$ver" 9 9 15 "scala:" $'\uE737 '
}
