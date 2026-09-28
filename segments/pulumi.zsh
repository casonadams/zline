zline_segment_pulumi() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local proj=""
  if [[ -f "Pulumi.yaml" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "name:"* ]]; then
        proj="${line#name:}"
        proj="${proj//[[:space:]\'\"]/}"
        break
      fi
    done < "Pulumi.yaml" 2>/dev/null
  else
    local -a p_files=( Pulumi.*.yaml(N) )
    if (( ${#p_files} > 0 )); then
      proj="pulumi"
    fi
  fi

  local content=""
  if [[ -n "$proj" ]]; then
    if [[ -n "$PULUMI_STACK" ]]; then
      content="${proj}:${PULUMI_STACK}"
    else
      content="${proj}"
    fi
  fi

  if [[ -z "$content" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-13}"
  _zline_ret_bg="${opts[--bg]:-13}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="pulumi:"
  else
    _zline_ret_icon=$'\uF1B2 '
  fi
}
