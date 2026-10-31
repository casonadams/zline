zline_segment_php() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".php-version" ]]; then
    read -r ver < ".php-version" 2>/dev/null
  elif _zline_read_tool_version "php"; then
    ver="$REPLY"
  elif [[ -f "composer.json" ]]; then
    ver="php"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 5 5 15 "php:" $'\uE73D '
}
