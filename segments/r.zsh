zline_segment_r() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "r"; then
    ver="$REPLY"
  elif _zline_find_up "DESCRIPTION" ".Rprofile" "renv.lock"; then
    ver="r"
  else
    local -a r_files=( *.R(N) *.r(N) )
    if (( ${#r_files} > 0 )); then
      ver="r"
    fi
  fi

  _zline_segment_emit "$ver" 12 12 15 "r:" $'\uF1C0 '
}
