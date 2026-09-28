zline_segment_jobs() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local -i count=${#jobstates}
  if (( count == 0 )); then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${count}"
  _zline_ret_fg="${opts[--color]:-11}"
  _zline_ret_bg="${opts[--bg]:-3}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="jobs:"
  else
    _zline_ret_icon=$'\u2726 '
  fi
}
