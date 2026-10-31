zline_segment_haskell() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

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

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 5 5 15 "hs:" $'\uE777 '
}
