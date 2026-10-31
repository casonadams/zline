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
  _zline_segment_finish 11 11 0 "mise:" $'\uF0AD '
}
