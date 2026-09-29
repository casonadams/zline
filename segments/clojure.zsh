zline_segment_clojure() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "clojure"; then
    ver="$REPLY"
  elif _zline_find_up "deps.edn" "project.clj" "shadow-cljs.edn"; then
    ver="clj"
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_ret_fg="${opts[--color]:-10}"
  _zline_ret_bg="${opts[--bg]:-10}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="clj:"
  else
    _zline_ret_icon=$'\uE768 '
  fi
}
