zline_segment_helm() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$content" 14 14 0 "helm:" $'\u2388 '
}
