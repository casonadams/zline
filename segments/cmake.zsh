zline_segment_cmake() {
  emulate -L zsh
  setopt extended_glob
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$name" 4 4 15 "cmake:" $'\uE61D '
}
