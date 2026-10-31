zline_segment_ocaml() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

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

  _zline_segment_emit "$ver" 11 11 0 "ml:" $'\uE67A '
}
