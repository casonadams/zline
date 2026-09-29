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
  _zline_ret_fg="${opts[--color]:-12}"
  _zline_ret_bg="${opts[--bg]:-12}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="pl:"
  else
    _zline_ret_icon=$'\uE769 '
  fi
}
