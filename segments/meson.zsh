zline_segment_meson() {
  emulate -L zsh
  setopt extended_glob
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local name=""
  if _zline_find_up "meson.build"; then
    name="meson"
    local line
    while IFS= read -r line; do
      if [[ "$line" == *project[[:space:]]#\(* ]]; then
        local p="${line#*project[[:space:]]#\(}"
        p="${p##[[:space:]]#}"
        p="${p%%[,) ]*}"
        p="${p//[\"\']/}"
        if [[ -n "$p" ]]; then
          name="$p"
          break
        fi
      fi
    done < "$REPLY" 2>/dev/null || true
  elif _zline_find_up "meson_options.txt"; then
    name="meson"
  fi

  if [[ -z "$name" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${name}"
  _zline_ret_fg="${opts[--color]:-14}"
  _zline_ret_bg="${opts[--bg]:-14}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="meson:"
  else
    _zline_ret_icon=$'\uF0AD '
  fi
}
