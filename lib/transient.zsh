typeset -gi _zline_transient=0
typeset -gi _zline_transient_show_dir=0
typeset -g _zline_transient_symbol="❯"
typeset -g _zline_transient_color="10"
typeset -g _zline_vi_mode="main"

_zline_transient_line_finish() {
  (( _zline_transient == 0 )) && return 0
  if (( _zline_transient_show_dir == 1 )); then
    local d="${_zline_dir_cache_res:-%~}"
    PROMPT="%F{4}${d}%f %F{${_zline_transient_color}}${_zline_transient_symbol}%f "
  else
    PROMPT="%F{${_zline_transient_color}}${_zline_transient_symbol}%f "
  fi
  RPROMPT=""
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle reset-prompt 2>/dev/null
  fi
}

_zline_vi_keymap_select() {
  _zline_vi_mode="${KEYMAP:-main}"
  zline_hook run keymap_select "$_zline_vi_mode"
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle reset-prompt 2>/dev/null
  fi
}

_zline_transient_install() {
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle -N zle-line-finish _zline_transient_line_finish 2>/dev/null
    zle -N zle-keymap-select _zline_vi_keymap_select 2>/dev/null
  fi
}

_zline_transient_uninstall() {
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle -D zle-line-finish 2>/dev/null
    zle -D zle-keymap-select 2>/dev/null
  fi
}
