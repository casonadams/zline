zline_segment_ruby() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$ver" 1 1 15 "rb:" $'\uE21E '
}
