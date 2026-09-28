zline_segment_dotnet() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

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

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-5}"
  _zline_ret_bg="${opts[--bg]:-5}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="net:"
  else
    _zline_ret_icon=$'\uF031B '
  fi
}
