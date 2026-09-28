zline_segment_shlvl() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -threshold:=opts -color:=opts -warn:=opts -icon:=opts -bg:=opts -fg:=opts

  local -i thresh="${opts[--threshold]:-2}"
  local -i lvl="${SHLVL:-1}"

  if (( lvl < thresh )); then
    _zline_ret_content=""
    return 0
  fi

  local col="${opts[--color]:-11}"
  if (( lvl >= thresh + 1 )); then
    col="${opts[--warn]:-9}"
  fi

  _zline_ret_content="${lvl}"
  _zline_ret_fg="${opts[--color]:-$col}"
  _zline_ret_bg="${opts[--bg]:-$col}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="shlvl:"
  else
    _zline_ret_icon=$'\u2195 '
  fi
}
