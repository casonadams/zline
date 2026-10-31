zline_segment_elixir() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "elixir"; then
    ver="$REPLY"
  elif [[ -f "mix.exs" || -f "mix.lock" ]]; then
    ver="ex"
  fi

  _zline_segment_emit "$ver" 5 5 15 "ex:" $'\uE62D '
}
