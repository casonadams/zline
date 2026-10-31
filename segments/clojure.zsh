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
  _zline_segment_finish 10 10 0 "clj:" $'\uE768 '
}
