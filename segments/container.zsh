typeset -g _zline_cached_ctype=""
typeset -gi _zline_container_detected=0

zline_segment_container() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ctype=""
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    ctype="$WSL_DISTRO_NAME"
  elif [[ -n "$SNAP" ]]; then
    ctype="snap"
  elif (( _zline_container_detected == 1 )); then
    ctype="$_zline_cached_ctype"
  else
    if [[ -f "/.dockerenv" ]]; then
      ctype="docker"
    elif [[ -f "/run/.containerenv" ]]; then
      ctype="podman"
    elif [[ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]]; then
      ctype="wsl"
    elif [[ -f "/.flatpak-info" ]]; then
      ctype="flatpak"
    elif [[ -f "/run/systemd/container" ]]; then
      read -r ctype < "/run/systemd/container" 2>/dev/null
      [[ -z "$ctype" ]] && ctype="container"
    fi
    _zline_cached_ctype="$ctype"
    _zline_container_detected=1
  fi

  if [[ -z "$ctype" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ctype}"
  _zline_ret_fg="${opts[--color]:-14}"
  _zline_ret_bg="${opts[--bg]:-14}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="box:"
  else
    _zline_ret_icon=$'\u2B22 '
  fi
}
