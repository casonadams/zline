zline_segment_solidity() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "solidity"; then
    ver="$REPLY"
  elif _zline_find_up "foundry.toml" "hardhat.config.js" "hardhat.config.ts" "truffle-config.js"; then
    ver="sol"
  fi

  _zline_segment_emit "$ver" 8 8 15 "sol:" $'\uE62C '
}
