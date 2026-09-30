typeset -gi _zline_osc=1
typeset -gi _zline_osc_hyperlinks=0

typeset -g _zline_osc_host_prefix="file://${${HOST:-localhost}//\%/%%}"

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

  local clean_pwd="${PWD//\%/%%}"
  REPLY="%{"$'\e]133;A\e\\\e]7;'"${_zline_osc_host_prefix}${clean_pwd}"$'\e\\'"%}"
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
  [[ -o interactive && -t 1 ]] || return 0
  [[ "$TERM" == "dumb" || -z "$TERM" ]] && return 0
  print -n -r -- $'\e]133;C\e\\'
}

_zline_osc_on_precmd() {
  (( _zline_osc == 0 )) && return 0
  [[ -o interactive && -t 1 ]] || return 0
  [[ "$TERM" == "dumb" || -z "$TERM" ]] && return 0
  print -n -r -- $'\e]133;D;'${_zline_last_exit_code:-0}$'\e\\'
}

zline_hook add preexec _zline_osc_on_preexec
zline_hook add precmd _zline_osc_on_precmd
