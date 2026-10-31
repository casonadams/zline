zline_segment_mise() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local content=""
  if [[ -n "$MISE_ENV" ]]; then
    content="$MISE_ENV"
  elif _zline_find_up "mise.toml" ".mise.toml" "mise.local.toml"; then
    content="mise"
  fi

  _zline_segment_emit "$content" 11 11 0 "mise:" $'\uF0AD '
}
