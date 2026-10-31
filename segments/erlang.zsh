zline_segment_erlang() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_find_up ".erlang-version"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "erlang"; then
    ver="$REPLY"
  elif _zline_find_up "rebar.config" "erlang.mk"; then
    ver="erl"
  fi

  _zline_segment_emit "$ver" 9 9 15 "erl:" $'\uE7B1 '
}
