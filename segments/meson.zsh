zline_segment_meson() {
  emulate -L zsh
  setopt extended_glob
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$name" 14 14 0 "meson:" $'\uF0AD '
}
