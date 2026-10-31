zline_segment_direnv() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local content=""
  if [[ -n "$DIRENV_DIR" ]]; then
    local d="${DIRENV_DIR#-}"
    content="${d:t}"
    [[ -z "$content" ]] && content="env"
  elif [[ -n "$DIRENV_FILE" ]]; then
    content="env"
  fi

  if [[ -z "$content" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${content}"
  _zline_segment_finish 11 11 0 "direnv:" $'\u25BC '
}
