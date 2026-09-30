zline_segment_docker() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ctx="${DOCKER_CONTEXT:-$DOCKER_HOST}"
  if [[ -z "$ctx" && -f "${HOME}/.docker/config.json" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == *'"currentContext":'* ]]; then
        ctx="${line#*\"currentContext\":}"
        ctx="${ctx//[\",[:space:]\}]}"
        break
      fi
    done < "${HOME}/.docker/config.json" 2>/dev/null
  fi

  if [[ -z "$ctx" || "$ctx" == "default" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ctx}"
  _zline_ret_fg="${opts[--color]:-4}"
  _zline_ret_bg="${opts[--bg]:-4}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="docker:"
  else
    _zline_ret_icon=$'\uF308 '
  fi
}
