typeset -gi _zline_doctor_warnings=0
typeset -gi _zline_doctor_errors=0

_zline_doctor_print_status() {
  local check_status="$1"
  local title="$2"
  local detail="$3"

  case "$check_status" in
    ok)
      print -P "  %F{10}✓%f %B${title}%b: ${detail}"
      ;;
    warn)
      (( _zline_doctor_warnings += 1 ))
      print -P "  %F{11}!%f %B${title}%b: ${detail}"
      ;;
    error)
      (( _zline_doctor_errors += 1 ))
      print -P "  %F{9}✗%f %B${title}%b: ${detail}"
      ;;
  esac
}

_zline_doctor_check_zsh() {
  local -a parts=("${(s:.:)ZSH_VERSION}")
  local -i major="${parts[1]:-0}"
  local -i minor="${parts[2]:-0}"

  if (( major > 5 || (major == 5 && minor >= 8) )); then
    _zline_doctor_print_status "ok" "Zsh Version" "${ZSH_VERSION} (supported >= 5.8)"
  else
    _zline_doctor_print_status "error" "Zsh Version" "${ZSH_VERSION} (unsupported, requires >= 5.8)"
  fi
}

_zline_doctor_check_locale() {
  local loc="${LC_ALL:-${LC_CTYPE:-$LANG}}"
  if [[ "$loc" == *[uU][tT][fF]-8* ]]; then
    _zline_doctor_print_status "ok" "Locale" "${loc} (UTF-8 enabled)"
  else
    _zline_doctor_print_status "warn" "Locale" "${loc:-unset} (UTF-8 recommended for Nerd Font glyphs)"
  fi
}

_zline_doctor_check_terminal() {
  local term_info="${TERM:-unknown}"
  local col_info="Standard 16 colors"

  if [[ "$COLORTERM" == *(truecolor|24bit)* ]]; then
    col_info="24-bit TrueColor supported"
  elif [[ "$TERM" == *256color* ]]; then
    col_info="256-color palette supported"
  fi

  _zline_doctor_print_status "ok" "Terminal Capabilities" "${term_info} (${col_info})"
}

_zline_doctor_check_cache() {
  local cdir="${_zline_instant_cache_dir:-${XDG_CACHE_HOME:-$HOME/.cache}/zline}"
  if [[ -d "$cdir" && -w "$cdir" ]]; then
    _zline_doctor_print_status "ok" "Cache Directory" "${cdir} (writable)"
  elif mkdir -p "$cdir" 2>/dev/null; then
    _zline_doctor_print_status "ok" "Cache Directory" "${cdir} (created successfully)"
  else
    _zline_doctor_print_status "warn" "Cache Directory" "${cdir} (cannot write, instant prompt disabled)"
  fi
}

_zline_doctor_check_worker() {
  if (( _zline_worker_pid > 0 )); then
    _zline_doctor_print_status "ok" "Async Worker" "PID ${_zline_worker_pid} active (req_fd: ${_zline_worker_req_fd}, res_fd: ${_zline_worker_res_fd})"
  else
    _zline_doctor_print_status "ok" "Async Worker" "Idle / on-demand"
  fi
}

_zline_doctor_check_segments() {
  local -a invalid=()
  local seg
  for seg in "${_zline_compiled_left_names[@]}" "${_zline_compiled_right_names[@]}"; do
    [[ "$seg" == "newline" ]] && continue
    if (( ! $+functions[zline_segment_${seg}] && ! $+_zline_registered_segments[$seg] )); then
      invalid+=("$seg")
    fi
  done

  if (( ${#invalid} == 0 )); then
    _zline_doctor_print_status "ok" "Registered Segments" "All declared segments valid"
  else
    _zline_doctor_print_status "warn" "Unknown Segments" "${(j:, :)invalid}"
  fi
}

_zline_doctor_check_latency() {
  zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null
  local -F t0=$EPOCHREALTIME
  local -i i
  for (( i = 1; i <= 100; i++ )); do
    zline_render
  done
  local -F t1=$EPOCHREALTIME
  local -F avg_ms=$(( (t1 - t0) * 10.0 ))

  if (( avg_ms < 1.5 )); then
    _zline_doctor_print_status "ok" "Render Latency" "$(printf '%.3f ms/render (< 1.5 ms target)' "$avg_ms")"
  else
    _zline_doctor_print_status "warn" "Render Latency" "$(printf '%.3f ms/render' "$avg_ms")"
  fi
}

zline_doctor() {
  _zline_doctor_warnings=0
  _zline_doctor_errors=0

  print -P "%F{14}%B============================================================%b%f"
  print -P "%F{15}%B                   zline Health Doctor                      %b%f"
  print -P "%F{14}%B============================================================%b%f\n"

  _zline_doctor_check_zsh
  _zline_doctor_check_locale
  _zline_doctor_check_terminal
  _zline_doctor_check_cache
  _zline_doctor_check_worker
  _zline_doctor_check_segments
  _zline_doctor_check_latency

  print -P "\n%F{14}%B============================================================%b%f"
  if (( _zline_doctor_errors > 0 )); then
    print -P "%F{9}%BDoctor detected ${_zline_doctor_errors} error(s). Please review above.%b%f"
    return 1
  elif (( _zline_doctor_warnings > 0 )); then
    print -P "%F{11}%BDoctor completed with ${_zline_doctor_warnings} warning(s).%b%f"
    return 0
  else
    print -P "%F{10}%BEverything is healthy! zline is ready to fly.%b%f"
    return 0
  fi
}
