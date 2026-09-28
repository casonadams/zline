zline_segment_azure() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local sub=""
  if [[ -n "$ARM_SUBSCRIPTION_NAME" ]]; then
    sub="$ARM_SUBSCRIPTION_NAME"
  elif [[ -n "$AZURE_SUBSCRIPTION" ]]; then
    sub="$AZURE_SUBSCRIPTION"
  else
    local az_dir="${AZURE_CONFIG_DIR:-$HOME/.azure}"
    local prof="${az_dir}/azureProfile.json"
    if [[ -f "$prof" ]]; then
      local line
      local in_default=0
      local cand_name=""
      while IFS= read -r line; do
        if [[ "$line" == *'"isDefault": true'* ]]; then
          in_default=1
        fi
        if [[ "$line" == *'"name":'* ]]; then
          local val="${line#*\"name\":}"
          val="${val#*\"}"
          cand_name="${val%%\"*}"
        fi
        if (( in_default )) && [[ -n "$cand_name" ]]; then
          sub="$cand_name"
          break
        fi
      done < "$prof" 2>/dev/null
      [[ -z "$sub" && -n "$cand_name" ]] && sub="$cand_name"
    fi
  fi

  if [[ -z "$sub" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${sub}"
  _zline_ret_fg="${opts[--color]:-14}"
  _zline_ret_bg="${opts[--bg]:-14}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="az:"
  else
    _zline_ret_icon=$'\uF0C2 '
  fi
}
