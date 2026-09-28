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
  typeset -i total_sec=dur
  typeset -i ms=$(( (dur - total_sec) * 10 ))

  if (( total_sec < 60 )); then
    if (( total_sec < 10 )); then
      REPLY="${total_sec}.${ms}s"
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
    -min:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local min_val="${opts[--min]:-2}"
  min_val="${min_val%s}"
  typeset -F min_sec="${min_val:-2.0}"

  if (( _zline_last_duration < min_sec )); then
    _zline_ret_content=""
    return 0
  fi

  _zline_format_duration "$_zline_last_duration"
  _zline_ret_content="$REPLY"
  _zline_ret_fg="${opts[--color]:-11}"
  _zline_ret_bg="${opts[--bg]:-3}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="s:"
  else
    _zline_ret_icon=$'\uF252 '
  fi
}
