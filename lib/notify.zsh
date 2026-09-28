typeset -gi _zline_notify_enabled=0
typeset -gi _zline_notify_threshold=30
typeset -gi _zline_notify_force=0
typeset -g _zline_notify_last_cmd=""

_zline_notify_preexec() {
  emulate -L zsh
  (( _zline_notify_enabled == 0 )) && return 0
  _zline_notify_last_cmd="${1:-}"
}

_zline_notify_precmd() {
  emulate -L zsh
  (( _zline_notify_enabled == 0 )) && return 0
  if ! [[ -o interactive && -t 1 ]] && (( ! _zline_notify_force )); then
    return 0
  fi

  if (( _zline_last_duration >= _zline_notify_threshold )) && [[ -n "$_zline_notify_last_cmd" ]]; then
    local cmd="${_zline_notify_last_cmd[1,40]}"
    local dur_str
    _zline_format_duration "$_zline_last_duration" 1
    dur_str="$REPLY"
    local status_str="exit ${_zline_last_exit_code:-0}"

    print -n -u1 -- $'\e]777;notify;Command Finished ('"${dur_str}"$') ;'"${cmd}"' ('"${status_str}"')'$'\a'
    print -n -u1 -- $'\e]9;'"${cmd}"': finished in '"${dur_str}"' ('"${status_str}"')'$'\a'
  fi
  _zline_notify_last_cmd=""
}

_zline_notify_cmd() {
  emulate -L zsh
  local sub="${1:-status}"
  shift 2>/dev/null || true

  case "$sub" in
    on|enable)
      _zline_notify_enabled=1
      if [[ -n "$1" && "$1" == <-> ]]; then
        _zline_notify_threshold="$1"
      fi
      print -P "%F{10}✓%f Desktop notifications enabled (threshold: ${_zline_notify_threshold}s)"
      ;;
    off|disable)
      _zline_notify_enabled=0
      print -P "%F{11}Desktop notifications disabled%f"
      ;;
    threshold|--threshold)
      if [[ -n "$1" && "$1" == <-> ]]; then
        _zline_notify_threshold="$1"
        print -P "%F{10}✓%f Notification threshold set to ${_zline_notify_threshold}s"
      else
        print -u2 "Usage: zline notify threshold <seconds>"
        return 1
      fi
      ;;
    status)
      if (( _zline_notify_enabled )); then
        print -P "Notifications: %F{10}enabled%f (threshold: ${_zline_notify_threshold}s)"
      else
        print -P "Notifications: %F{11}disabled%f"
      fi
      ;;
    *)
      print -u2 "Usage: zline notify [on [secs]|off|threshold <secs>|status]"
      return 1
      ;;
  esac
}

zline_hook add preexec _zline_notify_preexec
zline_hook add precmd _zline_notify_precmd
