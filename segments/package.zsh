zline_segment_package() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  local cur="$PWD"
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    if [[ -f "${cur}/package.json" ]]; then
      local line
      while IFS= read -r line; do
        if [[ "$line" == *'"version":'* ]]; then
          local vpart="${line#*\"version\":}"
          vpart="${vpart#*\"}"
          ver="${vpart%%\"*}"
          break
        fi
      done < "${cur}/package.json" 2>/dev/null
      [[ -n "$ver" ]] && break
    elif [[ -f "${cur}/Cargo.toml" ]]; then
      local line
      while IFS= read -r line; do
        if [[ "$line" == "version = "* ]]; then
          ver="${line#version = }"
          ver="${ver//[\"\']}"
          break
        fi
      done < "${cur}/Cargo.toml" 2>/dev/null
      [[ -n "$ver" ]] && break
    fi
    [[ -e "${cur}/.git" ]] && break
    cur="${cur:h}"
  done

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-8}"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="v:"
  else
    _zline_ret_icon=$'\uF1B2 '
  fi
}
