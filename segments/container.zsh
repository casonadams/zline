zline_segment_container() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ctype=""
  if [[ -f "/.dockerenv" ]]; then
    ctype="docker"
  elif [[ -f "/run/.containerenv" ]]; then
    ctype="podman"
  elif [[ -n "$WSL_DISTRO_NAME" || -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]]; then
    ctype="${WSL_DISTRO_NAME:-wsl}"
  elif [[ -f "/.flatpak-info" ]]; then
    ctype="flatpak"
  elif [[ -n "$SNAP" ]]; then
    ctype="snap"
  elif [[ -f "/run/systemd/container" ]]; then
    read -r ctype < "/run/systemd/container" 2>/dev/null
    [[ -z "$ctype" ]] && ctype="container"
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
