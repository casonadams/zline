zmodload -F zsh/datetime b:strftime p:EPOCHSECONDS 2>/dev/null

zline_segment_time() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -format:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local fmt="${opts[--format]:-%H:%M}"
  local res=""
  strftime -s res "$fmt" "$EPOCHSECONDS" 2>/dev/null || res=""

  _zline_segment_emit "$res" 8 0 15 "" $'\uF017 '
}
