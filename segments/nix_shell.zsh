zline_segment_nix_shell() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local content=""
  if [[ -n "$IN_NIX_SHELL" ]]; then
    if [[ "$IN_NIX_SHELL" == "pure" ]]; then
      content="pure"
    elif [[ "$IN_NIX_SHELL" == "impure" ]]; then
      content="impure"
    elif [[ -n "$name" ]]; then
      content="$name"
    else
      content="nix"
    fi
  elif [[ -n "$NIX_BUILD_TOP" || ( -n "$name" && -n "$SHLVL" && -n "$NIX_PROFILES" ) ]]; then
    content="${name:-nix}"
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
    _zline_ret_icon="nix:"
  else
    _zline_ret_icon=$'\uF313 '
  fi
}
