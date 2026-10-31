zline_segment_shlvl() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -threshold:=opts -color:=opts -warn:=opts -icon:=opts -bg:=opts -fg:=opts

  local -i thresh="${opts[--threshold]:-2}"
  local -i lvl="${SHLVL:-1}"

  local col="${opts[--color]:-11}"
  if (( lvl >= thresh + 1 )); then
    col="${opts[--warn]:-9}"
  fi

  local content=""
  (( lvl >= thresh )) && content="$lvl"
  _zline_segment_emit "$content" "$col" "$col" 0 "shlvl:" $'\u2195 '
}
