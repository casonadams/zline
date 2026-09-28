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
  elif [[ -f ".python-version" ]]; then
    read -r name < ".python-version" 2>/dev/null
  elif _zline_read_tool_version "python"; then
    name="$REPLY"
  fi

  if [[ -z "$name" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${name}"
  _zline_ret_fg="${opts[--color]:-5}"
  _zline_ret_bg="${opts[--bg]:-5}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="(py)"
  else
    _zline_ret_icon=$'\uE235 '
  fi
}
