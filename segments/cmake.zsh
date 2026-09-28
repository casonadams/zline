zline_segment_cmake() {
  emulate -L zsh
  setopt extended_glob
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local name=""
  if [[ -f "CMakeLists.txt" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == *(#i)project[[:space:]]#\(* ]]; then
        local p="${line#*(#i)project[[:space:]]#\(}"
        p="${p##[[:space:]]#}"
        p="${p%%[) ]*}"
        p="${p//[\"\']/}"
        if [[ -n "$p" && "$p" != "VERSION" && "$p" != "LANGUAGES" && "$p" != "DESCRIPTION" ]]; then
          name="$p"
          break
        fi
      fi
    done < "CMakeLists.txt" 2>/dev/null
    [[ -z "$name" ]] && name="cmake"
  elif [[ -f "CMakePresets.json" || -f "CMakeCache.txt" ]]; then
    name="cmake"
  fi

  if [[ -z "$name" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${name}"
  _zline_ret_fg="${opts[--color]:-4}"
  _zline_ret_bg="${opts[--bg]:-4}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="cmake:"
  else
    _zline_ret_icon=$'\uE61D '
  fi
}
