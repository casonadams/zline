zline_segment_perl() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_find_up ".perl-version"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "perl"; then
    ver="$REPLY"
  elif _zline_find_up "cpanfile" "Makefile.PL" "Build.PL"; then
    ver="pl"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 12 12 15 "pl:" $'\uE769 '
}
