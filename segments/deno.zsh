zline_segment_deno() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "deno"; then
    ver="$REPLY"
  elif [[ -f "deno.json" || -f "deno.jsonc" || -f "deno.lock" ]]; then
    ver="deno"
  fi

  _zline_segment_emit "$ver" 10 10 0 "deno:" $'\uE628 '
}
