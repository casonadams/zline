zline_segment_gcp() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local proj=""
  if [[ -n "$CLOUDSDK_CORE_PROJECT" ]]; then
    proj="$CLOUDSDK_CORE_PROJECT"
  elif [[ -n "$GCP_PROJECT" ]]; then
    proj="$GCP_PROJECT"
  elif [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    proj="$GOOGLE_CLOUD_PROJECT"
  else
    local gdir="${CLOUDSDK_CONFIG:-$HOME/.config/gcloud}"
    local cfg_name="${CLOUDSDK_ACTIVE_CONFIG_NAME:-}"
    if [[ -z "$cfg_name" && -f "${gdir}/active_config" ]]; then
      read -r cfg_name < "${gdir}/active_config" 2>/dev/null
    fi
    cfg_name="${cfg_name:-default}"
    local cfg_file="${gdir}/configurations/config_${cfg_name}"
    if [[ -f "$cfg_file" ]]; then
      local line
      while IFS= read -r line; do
        if [[ "$line" == "project ="* || "$line" == "project="* ]]; then
          local p="${line#*=}"
          proj="${p//[[:space:]]/}"
          break
        fi
      done < "$cfg_file" 2>/dev/null
    fi
  fi

  if [[ -z "$proj" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${proj}"
  _zline_segment_finish 12 12 0 "gcp:" $'\uF0C2 '
}
