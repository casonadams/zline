typeset -gi _zline_last_exit_code=0

zline_segment_status() {
  local -A opts=()
  local -a flags=()
  zparseopts -E -D -A opts -K \
    -hide-zero=flags -show-zero=flags -signal=flags \
    -color:=opts -ok:=opts -icon:=opts -bg:=opts -fg:=opts

  local -i code=${_zline_last_exit_code:-0}

  if (( code == 0 )); then
    if (( ${flags[(Ie)--show-zero]} > 0 )); then
      _zline_ret_content="0"
      _zline_ret_fg="${opts[--ok]:-10}"
      _zline_ret_bg="${opts[--bg]:-2}"
    else
      _zline_ret_content=""
      return 0
    fi
  else
    _zline_ret_content="${code}"
    _zline_ret_fg="${opts[--color]:-9}"
    _zline_ret_bg="${opts[--bg]:-1}"
  fi

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="!"
  else
    _zline_ret_icon=$'\u2718 '
  fi
}
