typeset -gA _ZLINE_COLOR_MAP=(
  black 0
  red 1
  green 2
  yellow 3
  blue 4
  magenta 5
  cyan 6
  white 7
  bright-black 8
  grey 8
  gray 8
  bright-red 9
  bright-green 10
  bright-yellow 11
  bright-blue 12
  bright-magenta 13
  bright-cyan 14
  bright-white 15
)

_zline_color_code() {
  if [[ "$1" == <-> ]]; then
    REPLY="$1"
    return 0
  fi
  if [[ -z "$1" || "$1" == "none" || "$1" == "transparent" || "$1" == "default" || "$1" == "reset" ]]; then
    REPLY="reset"
    return 0
  fi
  local val="${1:l}"
  if [[ -n "${_ZLINE_COLOR_MAP[$val]}" ]]; then
    REPLY="${_ZLINE_COLOR_MAP[$val]}"
    return 0
  fi
  REPLY="$1"
  return 0
}

_zline_fg() {
  local code
  _zline_color_code "$1"
  code="$REPLY"
  if [[ "$code" == "reset" ]]; then
    REPLY="%f"
  else
    REPLY="%F{${code}}"
  fi
}

_zline_bg() {
  local code
  _zline_color_code "$1"
  code="$REPLY"
  if [[ "$code" == "reset" ]]; then
    REPLY="%k"
  else
    REPLY="%K{${code}}"
  fi
}

_zline_wrap_raw() {
  local seq="$1"
  if [[ -z "$seq" ]]; then
    REPLY=""
  else
    REPLY="%{${seq}%}"
  fi
}
