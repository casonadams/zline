zline_segment_solidity() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "solidity"; then
    ver="$REPLY"
  elif _zline_find_up "foundry.toml" "hardhat.config.js" "hardhat.config.ts" "truffle-config.js"; then
    ver="sol"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 8 8 15 "sol:" $'\uE62C '
}
