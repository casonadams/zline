zline_segment_ruby() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if [[ -f ".ruby-version" ]]; then
    read -r ver < ".ruby-version" 2>/dev/null
  elif [[ -n "$RUBY_VERSION" ]]; then
    ver="$RUBY_VERSION"
  elif _zline_read_tool_version "ruby"; then
    ver="$REPLY"
  elif [[ -f "Gemfile" ]]; then
    ver="ruby"
  fi

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
    _zline_ret_icon="rb:"
  else
    _zline_ret_icon=$'\uE21E '
  fi
}
