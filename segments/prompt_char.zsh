zline_segment_prompt_char() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -symbol:=opts -error:=opts -color:=opts \
    -root:=opts -vi-cmd:=opts -vi-color:=opts

  local sym="${opts[--symbol]:-❯}"
  local col="${opts[--color]:-15}"

  if [[ "$_zline_mode" == "ascii" ]]; then
    sym="${opts[--symbol]:-$}"
  fi

  if (( EUID == 0 )); then
    sym="${opts[--root]:-#}"
    col="9"
  elif [[ "$_zline_vi_mode" == "vicmd" ]]; then
    sym="${opts[--vi-cmd]:-❮}"
    col="${opts[--vi-color]:-11}"
  elif (( ${_zline_last_exit_code:-0} != 0 )); then
    col="${opts[--error]:-9}"
  fi

  _zline_ret_content="${sym}"
  _zline_ret_fg="${col}"
  _zline_ret_bg="none"
  _zline_ret_icon=""
}
