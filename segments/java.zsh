zline_segment_java() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f ".java-version" ]]; then
    read -r ver < ".java-version" 2>/dev/null
  elif _zline_read_tool_version "java"; then
    ver="$REPLY"
  elif [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
    ver="java"
  fi

  _zline_segment_emit "$ver" 3 3 0 "java:" $'\uE738 '
}
