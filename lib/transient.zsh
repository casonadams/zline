typeset -gi _zline_transient=0
typeset -gi _zline_transient_show_dir=0
typeset -g _zline_transient_symbol="❯"
typeset -g _zline_transient_color="10"
typeset -g _zline_vi_mode="main"
typeset -gi _zline_vi_cursor=1
typeset -g _zline_orig_zle_line_finish=""
typeset -g _zline_orig_zle_keymap_select=""


_zline_transient_line_finish() {
  (( _zline_transient == 0 )) && return 0
  if (( _zline_vi_cursor == 1 )) && [[ -o interactive && -t 1 ]]; then
    print -n -P $'\e[6 q'
  fi
  if (( _zline_transient_show_dir == 1 )); then
    local d="${_zline_dir_cache_res:-%~}"
    PROMPT="%F{4}${d}%f %F{${_zline_transient_color}}${_zline_transient_symbol}%f "
  else
    PROMPT="%F{${_zline_transient_color}}${_zline_transient_symbol}%f "
  fi
  RPROMPT=""
  zline_hook run line_finish
  if [[ -n "$_zline_orig_zle_line_finish" ]]; then
    local orig_fn="${_zline_orig_zle_line_finish#user:}"
    if (( $+functions[$orig_fn] )); then
      "$orig_fn" "$@"
    fi
  fi
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle reset-prompt 2>/dev/null
  fi
}

_zline_vi_keymap_select() {
  _zline_vi_mode="${KEYMAP:-main}"
  if (( _zline_vi_cursor == 1 )) && [[ -o interactive && -t 1 ]]; then
    if [[ "$_zline_vi_mode" == "vicmd" ]]; then
      print -n -P $'\e[2 q'
    else
      print -n -P $'\e[6 q'
    fi
  fi
  zline_hook run keymap_select "$_zline_vi_mode"
  if [[ -n "$_zline_orig_zle_keymap_select" ]]; then
    local orig_fn="${_zline_orig_zle_keymap_select#user:}"
    if (( $+functions[$orig_fn] )); then
      "$orig_fn" "$@"
    fi
  fi
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zle reset-prompt 2>/dev/null
  fi
}

_zline_transient_install() {
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    if (( $+widgets[zle-line-finish] )) && [[ "$widgets[zle-line-finish]" != "user:_zline_transient_line_finish" ]]; then
      _zline_orig_zle_line_finish="$widgets[zle-line-finish]"
    fi
    if (( $+widgets[zle-keymap-select] )) && [[ "$widgets[zle-keymap-select]" != "user:_zline_vi_keymap_select" ]]; then
      _zline_orig_zle_keymap_select="$widgets[zle-keymap-select]"
    fi
    zle -N zle-line-finish _zline_transient_line_finish 2>/dev/null
    zle -N zle-keymap-select _zline_vi_keymap_select 2>/dev/null
  fi
}

_zline_transient_uninstall() {
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    if [[ -n "$_zline_orig_zle_line_finish" ]]; then
      zle -N zle-line-finish "${_zline_orig_zle_line_finish#user:}" 2>/dev/null
      _zline_orig_zle_line_finish=""
    else
      zle -D zle-line-finish 2>/dev/null
    fi
    if [[ -n "$_zline_orig_zle_keymap_select" ]]; then
      zle -N zle-keymap-select "${_zline_orig_zle_keymap_select#user:}" 2>/dev/null
      _zline_orig_zle_keymap_select=""
    else
      zle -D zle-keymap-select 2>/dev/null
    fi
  fi
}
