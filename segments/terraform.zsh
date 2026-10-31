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
  _zline_segment_finish 5 5 15 "tf:" $'\uF15B '
}
