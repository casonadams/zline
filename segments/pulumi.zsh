zline_segment_pulumi() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$content" 13 13 15 "pulumi:" $'\uF1B2 '
}
