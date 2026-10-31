typeset -g _zline_docker_cache_file=""
typeset -g _zline_docker_cache_ctx=""
typeset -g _zline_docker_cache_stamp=""

zline_segment_docker() {
  local -A opts=()
  _zline_std_opts "$@"

  local ctx="${DOCKER_CONTEXT:-$DOCKER_HOST}"
  local config_file="${HOME}/.docker/config.json"
  if [[ -z "$ctx" && -f "$config_file" ]]; then
    _zline_file_stamp "$config_file"
    local stamp="$REPLY"
    if [[ -n "$stamp" && "$stamp" == "$_zline_docker_cache_stamp" && "$config_file" == "$_zline_docker_cache_file" ]]; then
      ctx="$_zline_docker_cache_ctx"
    else
      local line
      while IFS= read -r line; do
        if [[ "$line" == *'"currentContext":'* ]]; then
          ctx="${line#*\"currentContext\":}"
          ctx="${ctx//[\",[:space:]\}]}"
          break
        fi
      done < "$config_file" 2>/dev/null
      _zline_docker_cache_stamp="$stamp"
      _zline_docker_cache_file="$config_file"
      _zline_docker_cache_ctx="$ctx"
    fi
  fi

  [[ "$ctx" == "default" ]] && ctx=""
  _zline_segment_emit "$ctx" 4 4 15 "docker:" $'\uF308 '
}
