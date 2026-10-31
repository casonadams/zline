zline_segment_julia() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "julia"; then
    ver="$REPLY"
  elif [[ -f "Project.toml" || -f "JuliaProject.toml" ]]; then
    ver="jl"
  fi

  _zline_segment_emit "$ver" 13 13 15 "jl:" $'\uE624 '
}
