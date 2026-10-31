zline_segment_php() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f ".php-version" ]]; then
    read -r ver < ".php-version" 2>/dev/null
  elif _zline_read_tool_version "php"; then
    ver="$REPLY"
  elif [[ -f "composer.json" ]]; then
    ver="php"
  fi

  _zline_segment_emit "$ver" 5 5 15 "php:" $'\uE73D '
}
