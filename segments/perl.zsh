zline_segment_perl() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_find_up ".perl-version"; then
    read -r ver < "$REPLY" 2>/dev/null
  elif _zline_read_tool_version "perl"; then
    ver="$REPLY"
  elif _zline_find_up "cpanfile" "Makefile.PL" "Build.PL"; then
    ver="pl"
  fi

  _zline_segment_emit "$ver" 12 12 15 "pl:" $'\uE769 '
}
