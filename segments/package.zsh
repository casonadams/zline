zline_segment_package() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_find_up "package.json"; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == *'"version":'* ]]; then
        local vpart="${line#*\"version\":}"
        vpart="${vpart#*\"}"
        ver="${vpart%%\"*}"
        break
      fi
    done < "$REPLY" 2>/dev/null
  elif _zline_find_up "Cargo.toml" "pyproject.toml"; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "version = "* ]]; then
        ver="${line#version = }"
        ver="${ver//[\"\']}"
        break
      fi
    done < "$REPLY" 2>/dev/null
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 8 0 15 "v:" $'\uF1B2 '
}
