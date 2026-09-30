typeset -g _zline_ram_cached_macos=""

_zline_ram_read() {
  local -i total=0
  local -i avail=0

  if [[ -r "/proc/meminfo" ]]; then
    local line
    while IFS= read -r line; do
      if [[ "$line" == "MemTotal:"* ]]; then
        local -a parts=(${=line})
        total="${parts[2]}"
      elif [[ "$line" == "MemAvailable:"* ]]; then
        local -a parts=(${=line})
        avail="${parts[2]}"
      fi
      (( total > 0 && avail > 0 )) && break
    done < "/proc/meminfo" 2>/dev/null

    if (( total > 0 )); then
      local -i used=$(( total - avail ))
      local -i pct=$(( used * 100 / total ))
      REPLY="${pct}%"
      return 0
    fi
  elif [[ $+commands[vm_stat] -eq 1 && $+commands[sysctl] -eq 1 ]]; then
    if [[ -n "$_zline_ram_cached_macos" ]]; then
      REPLY="$_zline_ram_cached_macos"
      return 0
    fi
    local mem_total
    mem_total=$(sysctl -n hw.memsize 2>/dev/null)
    if (( mem_total > 0 )); then
      local -i total_gb=$(( mem_total / 1073741824 ))
      _zline_ram_cached_macos="${total_gb}G"
      REPLY="$_zline_ram_cached_macos"
      return 0
    fi
  fi

  REPLY=""
  return 0
}

zline_segment_ram() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -warn:=opts -warn-color:=opts -color:=opts -icon:=opts -bg:=opts -fg:=opts

  _zline_ram_read
  local mem="$REPLY"
  if [[ -z "$mem" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${mem}"

  local col="${opts[--color]:-8}"
  if [[ "$mem" == *% ]]; then
    local -i pct="${mem%%%}"
    local -i w="${opts[--warn]:-80}"
    if (( pct >= w )); then
      col="${opts[--warn-color]:-9}"
    fi
  fi

  _zline_ret_fg="$col"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="ram:"
  else
    _zline_ret_icon=$'\uF035B '
  fi
  return 0
}
