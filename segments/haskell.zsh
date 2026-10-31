zline_segment_haskell() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "haskell" || _zline_read_tool_version "ghc"; then
    ver="$REPLY"
  elif [[ -f "stack.yaml" || -f "cabal.project" ]]; then
    ver="hs"
  else
    local -a cabal_files=( *.cabal(N) )
    if (( ${#cabal_files} > 0 )); then
      ver="hs"
    fi
  fi

  _zline_segment_emit "$ver" 5 5 15 "hs:" $'\uE777 '
}
