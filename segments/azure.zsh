zline_segment_azure() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$sub" 14 14 0 "az:" $'\uF0C2 '
}
