zline_segment_venv() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local name=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    name="${VIRTUAL_ENV:t}"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    name="$CONDA_DEFAULT_ENV"
  elif [[ -n "$POETRY_ACTIVE" ]]; then
    name="poetry"
  elif _zline_find_up ".python-version"; then
    read -r name < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "python"; then
    name="$REPLY"
  fi

  if [[ -z "$name" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${name}"
  _zline_segment_finish 5 5 15 "(py)" $'\uE235 '
}
