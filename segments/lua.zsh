zline_segment_lua() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f ".lua-version" ]]; then
    read -r ver < ".lua-version" 2>/dev/null
  elif _zline_read_tool_version "lua"; then
    ver="$REPLY"
  elif [[ -f "init.lua" || -f "main.lua" ]]; then
    ver="lua"
  else
    local rocks=( *.rockspec(N) )
    if (( ${#rocks} > 0 )); then
      ver="lua"
    fi
  fi

  _zline_segment_emit "$ver" 4 4 15 "lua:" $'\uE620 '
}
