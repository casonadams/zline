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
  _zline_ret_fg="${opts[--color]:-8}"
  _zline_ret_bg="${opts[--bg]:-8}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="sol:"
  else
    _zline_ret_icon=$'\uE62C '
  fi
}
