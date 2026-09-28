zline_segment_text() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -content:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local str="${opts[--content]:-${1:-}}"
  if [[ "$str" == *\$* ]]; then
    str="${(e)str}"
  fi

  if [[ -z "$str" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${str}"
  _zline_ret_fg="${opts[--color]:-7}"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  else
    _zline_ret_icon=""
  fi
}
