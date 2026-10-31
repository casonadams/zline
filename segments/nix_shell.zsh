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
  _zline_segment_finish 14 14 0 "nix:" $'\uF313 '
}
