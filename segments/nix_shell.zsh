zline_segment_nix_shell() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$content" 14 14 0 "nix:" $'\uF313 '
}
