typeset -g _zline_load_cache=""
typeset -gi _zline_load_cache_ts=0

_zline_load_read() {
  zmodload -F zsh/datetime p:EPOCHSECONDS 2>/dev/null
  if (( _zline_load_cache_ts > 0 && EPOCHSECONDS - _zline_load_cache_ts < 3 )); then
    REPLY="$_zline_load_cache"
    return 0
  fi

  local lavg=""
  if [[ -r "/proc/loadavg" ]]; then
    local line
    read -r lavg rest < "/proc/loadavg" 2>/dev/null
  elif [[ $+commands[sysctl] -eq 1 ]]; then
    local out
    out=$(sysctl -n vm.loadavg 2>/dev/null)
    if [[ "$out" =~ '\{ ([0-9.]+) ' ]]; then
      lavg="${match[1]}"
    fi
  fi
  _zline_load_cache="$lavg"
  _zline_load_cache_ts=$EPOCHSECONDS
  REPLY="$lavg"
}

zline_segment_load() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -warn:=opts -warn-color:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  _zline_load_read
  local lavg="$REPLY"
  if [[ -z "$lavg" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${lavg}"

  local -F lval=lavg
  local -F wval="${opts[--warn]:-4.0}"
  local col="${opts[--color]:-8}"
  if (( lval >= wval )); then
    col="${opts[--warn-color]:-9}"
  fi

  _zline_ret_fg="$col"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="load:"
  else
    _zline_ret_icon=$'\uF04C5 '
  fi
}
