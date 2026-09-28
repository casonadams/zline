zline_segment_scala() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

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

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-9}"
  _zline_ret_bg="${opts[--bg]:-9}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="scala:"
  else
    _zline_ret_icon=$'\uE737 '
  fi
}
