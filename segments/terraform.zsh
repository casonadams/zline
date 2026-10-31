zline_segment_terraform() {
  local -A opts=()
  _zline_std_opts "$@"

  local ws="${TF_WORKSPACE}"
  if [[ -z "$ws" && -f ".terraform/environment" ]]; then
    read -r ws < ".terraform/environment" 2>/dev/null
  fi

  [[ "$ws" == "default" ]] && ws=""
  _zline_segment_emit "$ws" 5 5 15 "tf:" $'\uF15B '
}
