zmodload -F zsh/datetime b:strftime p:EPOCHSECONDS 2>/dev/null

zline_segment_time() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -format:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local fmt="${opts[--format]:-%H:%M}"
  local res=""
  strftime -s res "$fmt" "$EPOCHSECONDS" 2>/dev/null || res=""

  if [[ -z "$res" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${res}"
  _zline_ret_fg="${opts[--color]:-8}"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon=""
  else
    _zline_ret_icon=$'\uF017 '
  fi
}
