zline_segment_java() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".java-version" ]]; then
    read -r ver < ".java-version" 2>/dev/null
  elif _zline_read_tool_version "java"; then
    ver="$REPLY"
  elif [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
    ver="java"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 3 3 0 "java:" $'\uE738 '
}
