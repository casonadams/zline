zline_segment_java() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".java-version" ]]; then
    read -r ver < ".java-version" 2>/dev/null
  elif [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
    ver="java"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-3}"
  _zline_ret_bg="${opts[--bg]:-3}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="java:"
  else
    _zline_ret_icon=$'\uE738 '
  fi
}
