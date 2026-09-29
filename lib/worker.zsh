zmodload -F zsh/system b:sysopen 2>/dev/null

typeset -g _zline_worker_pid=0
typeset -g _zline_worker_req_fd=-1
typeset -g _zline_worker_res_fd=-1
typeset -g _zline_worker_tmpdir=""
typeset -gi _zline_worker_seq=0
typeset -gi _zline_worker_last_acked=0
typeset -gi _zline_worker_pending=0
typeset -g _zline_worker_pending_dir=""
typeset -g _zline_git_provider="cli"

_zline_worker_git_task() {
  local seq="$1"
  local dir="$2"

  if [[ "$_zline_git_provider" != "cli" && $+functions[_zline_git_provider_${_zline_git_provider}] -eq 1 ]]; then
    "_zline_git_provider_${_zline_git_provider}" "$seq" "$dir"
    return $?
  fi

  local -i staged=0 unstaged=0 untracked=0 ahead=0 behind=0 conflicts=0
  local branch=""

  local raw
  raw=$(git -C "$dir" status --porcelain=v2 --branch 2>/dev/null) || {
    print -r -- "${seq}:git:none:0:0:0:0:0:0"
    return 0
  }

  local line
  while IFS= read -r line; do
    case "${line[1]}" in
      "#")
        if [[ "$line" == "# branch.head "* ]]; then
          branch="${line#\# branch.head }"
        elif [[ "$line" == "# branch.ab "* ]]; then
          local ab="${line#\# branch.ab }"
          local -a ab_parts=(${=ab})
          ahead="${ab_parts[1]#+}"
          behind="${ab_parts[2]#-}"
        fi
        ;;
      "1"|"2")
        local xy="${line[3,4]}"
        [[ "${xy[1]}" != "." ]] && (( staged += 1 ))
        [[ "${xy[2]}" != "." ]] && (( unstaged += 1 ))
        ;;
      "u")
        (( conflicts += 1 ))
        ;;
      "?")
        (( untracked += 1 ))
        ;;
    esac
  done <<< "$raw"

  print -r -- "${seq}:git:${branch}:${staged}:${unstaged}:${untracked}:${ahead}:${behind}:${conflicts}"
}

_zline_worker_loop() {
  local req_pipe="$1"
  local res_pipe="$2"

  exec 3<"$req_pipe"
  exec 4>"$res_pipe"

  local line
  while read -u 3 -r line; do
    [[ "$line" == "quit" ]] && break
    local seq="${line%%:*}"
    local rest="${line#*:}"
    local type="${rest%%:*}"
    local dir="${rest#*:}"

    if [[ "$type" == "git" ]]; then
      _zline_worker_git_task "$seq" "$dir" >&4
    fi
  done

  exec 3<&-
  exec 4>&-
}

_zline_worker_start() {
  emulate -L zsh
  (( _zline_worker_pid > 0 )) && return 0
  if [[ ! -o interactive && "$1" != "--force" ]]; then
    return 0
  fi

  _zline_worker_tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/zline-worker.XXXXXX" 2>/dev/null) || return 0
  local req_pipe="${_zline_worker_tmpdir}/req"
  local res_pipe="${_zline_worker_tmpdir}/res"
  mkfifo "$req_pipe" "$res_pipe" 2>/dev/null || { rm -rf "$_zline_worker_tmpdir" 2>/dev/null; return 0; }

  ( _zline_worker_loop "$req_pipe" "$res_pipe" ) </dev/null >/dev/null 2>&1 &!
  _zline_worker_pid=$!

  if (( $+builtins[sysopen] )); then
    sysopen -w -o cloexec -u _zline_worker_req_fd "$req_pipe" 2>/dev/null || { _zline_worker_stop; return 0; }
    sysopen -r -o cloexec -u _zline_worker_res_fd "$res_pipe" 2>/dev/null || { _zline_worker_stop; return 0; }
  else
    { exec {_zline_worker_req_fd}>"$req_pipe" } 2>/dev/null || { _zline_worker_stop; return 0; }
    { exec {_zline_worker_res_fd}<"$res_pipe" } 2>/dev/null || { _zline_worker_stop; return 0; }
  fi

  if [[ -o interactive ]] && (( $+widgets[zle-line-init] || $+functions[zle] )); then
    zle -F "$_zline_worker_res_fd" _zline_worker_zle_handler 2>/dev/null
  fi
}

_zline_worker_stop() {
  if (( _zline_worker_req_fd >= 0 )); then
    print -u "$_zline_worker_req_fd" "quit" 2>/dev/null
    exec {_zline_worker_req_fd}>&-
    _zline_worker_req_fd=-1
  fi

  if (( _zline_worker_res_fd >= 0 )); then
    if [[ -o interactive ]] && (( $+functions[zle] )); then
      zle -F "$_zline_worker_res_fd" 2>/dev/null
    fi
    exec {_zline_worker_res_fd}<&-
    _zline_worker_res_fd=-1
  fi

  if (( _zline_worker_pid > 0 )); then
    kill -TERM "$_zline_worker_pid" 2>/dev/null
    _zline_worker_pid=0
  fi

  if [[ -n "$_zline_worker_tmpdir" && -d "$_zline_worker_tmpdir" ]]; then
    rm -rf "$_zline_worker_tmpdir"
    _zline_worker_tmpdir=""
  fi
}

zline_hook add zshexit _zline_worker_stop

_zline_worker_send() {
  local type="$1"
  local dir="$2"
  (( _zline_worker_req_fd < 0 )) && return 1

  if (( _zline_worker_pending == 1 )) && [[ "$dir" == "$_zline_worker_pending_dir" ]]; then
    return 0
  fi

  (( _zline_worker_seq += 1 ))
  _zline_worker_pending=1
  _zline_worker_pending_dir="$dir"
  print -u "$_zline_worker_req_fd" -r -- "${_zline_worker_seq}:${type}:${dir}"
}

_zline_worker_apply_reply() {
  local reply="$1"
  local -a parts=("${(s/:/)reply}")
  local -i seq="${parts[1]}"
  local type="${parts[2]}"

  _zline_worker_pending=0
  _zline_worker_pending_dir=""

  if (( seq < _zline_worker_last_acked )); then
    return 0
  fi
  _zline_worker_last_acked=$seq

  if [[ "$type" == "git" ]]; then
    _zline_git_cache_branch="${parts[3]}"
    _zline_git_cache_staged="${parts[4]:-0}"
    _zline_git_cache_unstaged="${parts[5]:-0}"
    _zline_git_cache_untracked="${parts[6]:-0}"
    _zline_git_cache_ahead="${parts[7]:-0}"
    _zline_git_cache_behind="${parts[8]:-0}"
    _zline_git_cache_conflicts="${parts[9]:-0}"
    _zline_git_cache_valid=1
  fi
}

_zline_worker_poll() {
  (( _zline_worker_res_fd < 0 )) && return 1
  local reply=""
  if read -t 0.5 -u "$_zline_worker_res_fd" -r reply 2>/dev/null; then
    [[ -n "$reply" ]] && _zline_worker_apply_reply "$reply"
  fi
}

_zline_worker_zle_handler() {
  local fd="$1"
  local reply=""
  if read -u "$fd" -r reply; then
    _zline_worker_apply_reply "$reply"
    zline_hook run async_reply "git"
    zle reset-prompt 2>/dev/null
  fi
}
