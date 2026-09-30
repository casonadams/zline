typeset -g _zline_battery_cache=""
typeset -gi _zline_battery_cache_ts=0

_zline_battery_read() {
  zmodload -F zsh/datetime p:EPOCHSECONDS 2>/dev/null
  if (( _zline_battery_cache_ts > 0 && EPOCHSECONDS - _zline_battery_cache_ts < 30 )); then
    REPLY="$_zline_battery_cache"
    return 0
  fi

  local cap=""
  local stat=""

  local bat_cap
  for bat_cap in /sys/class/power_supply/(BAT*|battery)/capacity(N); do
    read -r cap < "$bat_cap" 2>/dev/null
    local bat_stat="${bat_cap:h}/status"
    [[ -r "$bat_stat" ]] && read -r stat < "$bat_stat" 2>/dev/null
    break
  done

  if [[ -z "$cap" && $+commands[pmset] -eq 1 ]]; then
    local pm_out
    pm_out=$(pmset -g batt 2>/dev/null)
    if [[ "$pm_out" =~ "([0-9]+)%" ]]; then
      cap="${match[1]}"
      [[ "$pm_out" == *"charging"* || "$pm_out" == *"AC Power"* ]] && stat="Charging"
    fi
  fi

  _zline_battery_cache="${cap}:${stat}"
  _zline_battery_cache_ts=$EPOCHSECONDS
  REPLY="$_zline_battery_cache"
}

zline_segment_battery() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -warn:=opts -charging:=opts -icon:=opts -bg:=opts -fg:=opts

  _zline_battery_read
  local info="$REPLY"
  local cap="${info%%:*}"
  local stat="${info#*:}"

  if [[ -z "$cap" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${cap}%"

  local -i pct=cap
  local col="${opts[--color]:-10}"
  if (( pct < 20 )); then
    col="${opts[--warn]:-9}"
  elif [[ "$stat" == "Charging" ]]; then
    col="${opts[--charging]:-10}"
  fi

  _zline_ret_fg="$col"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="bat:"
  elif (( pct < 20 )); then
    _zline_ret_icon=$'\uF0083 '
  else
    _zline_ret_icon=$'\uF0079 '
  fi
}
