typeset -g _zline_instant_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zline"
typeset -g _zline_instant_file="${_zline_instant_cache_dir}/instant-${(%):-%n}.zsh"
typeset -gi _zline_instant_enabled=1
typeset -g _zline_instant_last_prompt=""
typeset -g _zline_instant_last_rprompt=""

_zline_instant_save() {
  (( _zline_instant_enabled == 0 )) && return 0
  [[ -z "$PROMPT" ]] && return 0

  if [[ "$PROMPT" == "$_zline_instant_last_prompt" && "$RPROMPT" == "$_zline_instant_last_rprompt" ]]; then
    return 0
  fi
  _zline_instant_last_prompt="$PROMPT"
  _zline_instant_last_rprompt="$RPROMPT"

  [[ -d "$_zline_instant_cache_dir" ]] || mkdir -p "$_zline_instant_cache_dir" 2>/dev/null || return 0

  {
    print -r -- "typeset -g _ZLINE_INSTANT_ACTIVE=1"
    print -r -- "PROMPT='${PROMPT//\'/\'\\\'\'}'"
    print -r -- "RPROMPT='${RPROMPT//\'/\'\\\'\'}'"
    print -r -- "print -P -n -- \"\$PROMPT\""
  } >! "$_zline_instant_file" 2>/dev/null
}

_zline_instant_restore() {
  if (( _ZLINE_INSTANT_ACTIVE == 1 )); then
    _ZLINE_INSTANT_ACTIVE=0
  fi
}

zline_hook add post_render _zline_instant_save
