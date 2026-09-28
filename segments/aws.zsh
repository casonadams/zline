zline_segment_aws() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local profile="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-$AWS_VAULT}}"
  local region="${AWS_REGION:-$AWS_DEFAULT_REGION}"

  if [[ -z "$profile" && -z "$region" ]]; then
    _zline_ret_content=""
    return 0
  fi

  local content="$profile"
  if [[ -n "$region" ]]; then
    if [[ -n "$content" ]]; then
      content="${content} (${region})"
    else
      content="$region"
    fi
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-3}"
  _zline_ret_bg="${opts[--bg]:-3}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="aws:"
  else
    _zline_ret_icon=$'\u2601 '
  fi
}
