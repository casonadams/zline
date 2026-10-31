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
  _zline_segment_finish 4 4 15 "docker:" $'\uF308 '
}
