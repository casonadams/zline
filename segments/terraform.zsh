zline_segment_terraform() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ws="${TF_WORKSPACE}"
  if [[ -z "$ws" && -f ".terraform/environment" ]]; then
    read -r ws < ".terraform/environment" 2>/dev/null
  fi

  if [[ -z "$ws" || "$ws" == "default" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ws}"
  _zline_ret_fg="${opts[--color]:-5}"
  _zline_ret_bg="${opts[--bg]:-5}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="tf:"
  else
    _zline_ret_icon=$'\uF15B '
  fi
}
