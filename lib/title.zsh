typeset -gi _zline_title_enabled=1
typeset -g _zline_title_format="%~"

_zline_title_set() {
  (( _zline_title_enabled == 0 )) && return 0
  [[ -o interactive && -t 1 ]] || return 0
  [[ "$TERM" == "dumb" || -z "$TERM" ]] && return 0

  local title="$1"
  print -n -r -- $'\e]2;'${title}$'\a'
}

_zline_title_precmd() {
  (( _zline_title_enabled == 0 )) && return 0
  local fmt="${(%):-${_zline_title_format}}"
  _zline_title_set "${fmt} — zsh"
}

_zline_title_preexec() {
  (( _zline_title_enabled == 0 )) && return 0
  local cmd="${1:-zsh}"
  cmd="${cmd[1,30]}"
  _zline_title_set "${cmd} — zsh"
}

zline_hook add precmd _zline_title_precmd
zline_hook add preexec _zline_title_preexec
