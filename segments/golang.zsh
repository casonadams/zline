zline_segment_golang() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f "go.mod" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "go "* ]]; then
        ver="${line#go }"
        break
      fi
    done < "go.mod" 2>/dev/null
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-6}"
  _zline_ret_bg="${opts[--bg]:-6}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="go:"
  else
    _zline_ret_icon=$'\uE627 '
  fi
}
