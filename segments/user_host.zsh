zline_segment_user_host() {
  local -A opts=()
  local -a flags=()
  zparseopts -E -D -A opts -K \
    -always=flags \
    -color:=opts -bg:=opts -fg:=opts -icon:=opts \
    -root-color:=opts -ssh-color:=opts

  local -i is_root=0
  (( EUID == 0 )) && is_root=1

  local -i is_ssh=0
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]]; then
    is_ssh=1
  fi

  if (( is_root == 0 && is_ssh == 0 && ${flags[(Ie)--always]} == 0 )); then
    _zline_ret_content=""
    return 0
  fi

  local user_part="${USER:-${USERNAME:-${LOGNAME:-${(%):-%n}}}}"
  local host_part="${HOST:-localhost}"
  host_part="${host_part%%.*}"

  _zline_ret_content="${user_part}@${host_part}"

  local col="${opts[--color]:-8}"
  if (( is_root == 1 )); then
    col="${opts[--root-color]:-9}"
  elif (( is_ssh == 1 )); then
    col="${opts[--ssh-color]:-11}"
  fi

  _zline_ret_fg="$col"
  _zline_ret_bg="${opts[--bg]:-0}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon=""
  else
    _zline_ret_icon=$'\uF007 '
  fi
}
