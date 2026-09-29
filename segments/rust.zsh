zline_segment_rust() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  local cur="$PWD"
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    if [[ -f "${cur}/rust-toolchain" ]]; then
      read -r ver < "${cur}/rust-toolchain" 2>/dev/null
      break
    elif [[ -f "${cur}/rust-toolchain.toml" ]]; then
      local line
      while IFS= read -r line; do
        if [[ "$line" == *"channel ="* ]]; then
          ver="${line#*channel = }"
          ver="${ver//[\"\']}"
          break
        fi
      done < "${cur}/rust-toolchain.toml" 2>/dev/null
      break
    elif _zline_read_tool_version "rust"; then
      ver="$REPLY"
      break
    elif [[ -f "${cur}/Cargo.toml" ]]; then
      ver="rust"
      break
    fi
    [[ -e "${cur}/.git" ]] && break
    cur="${cur:h}"
  done

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-1}"
  _zline_ret_bg="${opts[--bg]:-1}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="rs:"
  else
    _zline_ret_icon=$'\uE7A8 '
  fi
}
