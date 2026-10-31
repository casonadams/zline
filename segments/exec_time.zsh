zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

typeset -F _zline_cmd_start_time=0.0
typeset -F _zline_last_duration=0.0

_zline_exec_time_preexec() {
  _zline_cmd_start_time=$EPOCHREALTIME
}

_zline_exec_time_precmd() {
  if (( _zline_cmd_start_time > 0.0 )); then
    _zline_last_duration=$(( EPOCHREALTIME - _zline_cmd_start_time ))
    _zline_cmd_start_time=0.0
  else
    _zline_last_duration=0.0
  fi
}

zline_hook add preexec _zline_exec_time_preexec
zline_hook add precmd _zline_exec_time_precmd

_zline_format_duration() {
  typeset -F dur="$1"
  local -i prec="${2:-1}"
  typeset -i total_sec=dur

  if (( total_sec < 60 )); then
    if (( total_sec < 10 || prec >= 2 )); then
      if (( prec >= 2 )); then
        local -i ms=$(( (dur - total_sec) * 100 ))
        local ms_str="$ms"
        (( ms < 10 )) && ms_str="0${ms}"
        REPLY="${total_sec}.${ms_str}s"
      else
        local -i ms=$(( (dur - total_sec) * 10 ))
        REPLY="${total_sec}.${ms}s"
      fi
    else
      REPLY="${total_sec}s"
    fi
  elif (( total_sec < 3600 )); then
    local -i m=$(( total_sec / 60 ))
    local -i s=$(( total_sec % 60 ))
    REPLY="${m}m ${s}s"
  else
    local -i h=$(( total_sec / 3600 ))
    local -i m=$(( (total_sec % 3600) / 60 ))
    REPLY="${h}h ${m}m"
  fi
}

zline_segment_exec_time() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -precision:=opts \
    -min:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local min_val="${opts[--min]:-2}"
  min_val="${min_val%s}"
  typeset -F min_sec="${min_val:-2.0}"

  local content=""
  if (( _zline_last_duration >= min_sec )); then
    _zline_format_duration "$_zline_last_duration" "${opts[--precision]:-1}"
    content="$REPLY"
  fi
  _zline_segment_emit "$content" 11 3 0 "s:" $'\uF252 '
}
