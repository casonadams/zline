zline_segment_dotnet() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if [[ -f "global.json" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == *'"version":'* ]]; then
        local vpart="${line#*\"version\":}"
        vpart="${vpart#*\"}"
        ver="${vpart%%\"*}"
        break
      fi
    done < "global.json" 2>/dev/null
  elif _zline_read_tool_version "dotnet"; then
    ver="$REPLY"
  else
    local -a dotnet_files=( *.(csproj|fsproj|sln)(N) )
    if (( ${#dotnet_files} > 0 )); then
      ver=".net"
    fi
  fi

  _zline_segment_emit "$ver" 5 5 15 "net:" $'\uF031B '
}
