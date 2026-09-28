zline_segment_helm() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local name=""
  local ver=""
  if [[ -f "Chart.yaml" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "name:"* ]]; then
        name="${line#name:}"
        name="${name//[[:space:]\'\"]/}"
      elif [[ "$line" == "version:"* ]]; then
        ver="${line#version:}"
        ver="${ver//[[:space:]\'\"]/}"
      fi
      [[ -n "$name" && -n "$ver" ]] && break
    done < "Chart.yaml" 2>/dev/null
  elif [[ -f "helmfile.yaml" || -f "helmfile.yaml.gotmpl" ]]; then
    name="helmfile"
  fi

  local content=""
  if [[ -n "$name" && -n "$ver" ]]; then
    content="${name}:${ver}"
  elif [[ -n "$name" ]]; then
    content="${name}"
  fi

  if [[ -z "$content" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-14}"
  _zline_ret_bg="${opts[--bg]:-14}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="helm:"
  else
    _zline_ret_icon=$'\u2388 '
  fi
}
