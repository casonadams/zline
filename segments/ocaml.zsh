zline_segment_ocaml() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local ver=""
  if _zline_read_tool_version "ocaml"; then
    ver="$REPLY"
  elif [[ -f "dune-project" || -f "dune" ]]; then
    ver="ml"
  else
    local -a opam_files=( *.opam(N) )
    if (( ${#opam_files} > 0 )); then
      ver="ml"
    fi
  fi

  if [[ -z "$ver" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ver}"
  _zline_segment_finish 11 11 0 "ml:" $'\uE67A '
}
