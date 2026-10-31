zline_segment_clojure() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local ver=""
  if _zline_read_tool_version "clojure"; then
    ver="$REPLY"
  elif _zline_find_up "deps.edn" "project.clj" "shadow-cljs.edn"; then
    ver="clj"
  fi

  _zline_segment_emit "$ver" 10 10 0 "clj:" $'\uE768 '
}
