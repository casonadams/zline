typeset -gi _zline_osc=1
typeset -gi _zline_osc_hyperlinks=0

_zline_osc_hyperlink() {
  local url="$1"
  local text="$2"

  if (( _zline_osc == 0 || _zline_osc_hyperlinks == 0 )) || [[ -z "$url" ]]; then
    REPLY="$text"
    return 0
  fi

  local open_seq=$'\e]8;;'${url}$'\e\\'
  local close_seq=$'\e]8;;\e\\'
  REPLY="%{${open_seq}%}${text}%{${close_seq}%}"
}

_zline_osc_prompt_prefix() {
  if (( _zline_osc == 0 )); then
    REPLY=""
    return 0
  fi

  local osc133=$'\e]133;A\e\\'
  local osc7=""
  if [[ -n "$PWD" ]]; then
    local host_part="${HOST:-localhost}"
    osc7=$'\e]7;file://'${host_part}${PWD}$'\e\\'
  fi

  REPLY="%{${osc133}${osc7}%}"
}

_zline_osc_prompt_suffix() {
  if (( _zline_osc == 0 )); then
    REPLY=""
    return 0
  fi

  REPLY="%{"$'\e]133;B\e\\'"%}"
}

_zline_osc_on_preexec() {
  (( _zline_osc == 0 )) && return 0
  [[ -o interactive ]] || return 0
  print -n -P $'\e]133;C\e\\'
}

_zline_osc_on_precmd() {
  (( _zline_osc == 0 )) && return 0
  [[ -o interactive ]] || return 0
  print -n -P $'\e]133;D;'${_zline_last_exit_code:-0}$'\e\\'
}

zline_hook add preexec _zline_osc_on_preexec
zline_hook add precmd _zline_osc_on_precmd
