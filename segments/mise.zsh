zline_segment_mise() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local content=""
  if [[ -n "$MISE_ENV" ]]; then
    content="$MISE_ENV"
  elif _zline_find_up "mise.toml" ".mise.toml" "mise.local.toml"; then
    content="mise"
  fi

  if [[ -z "$content" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-11}"
  _zline_ret_bg="${opts[--bg]:-11}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="mise:"
  else
    _zline_ret_icon=$'\uF0AD '
  fi
}
