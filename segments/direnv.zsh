zline_segment_direnv() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local content=""
  if [[ -n "$DIRENV_DIR" ]]; then
    local d="${DIRENV_DIR#-}"
    content="${d:t}"
    [[ -z "$content" ]] && content="env"
  elif [[ -n "$DIRENV_FILE" ]]; then
    content="env"
  fi

  _zline_segment_emit "$content" 11 11 0 "direnv:" $'\u25BC '
}
