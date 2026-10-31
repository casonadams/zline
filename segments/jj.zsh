_zline_find_jj_root() {
  emulate -L zsh
  local cur="$1"
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    if [[ -d "${cur}/.jj" ]]; then
      REPLY="$cur"
      return 0
    fi
    cur="${cur:h}"
  done
  REPLY=""
  return 1
}

zline_segment_jj() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local info=""
  _zline_find_jj_root "$PWD" && info="jj"
  _zline_segment_emit "$info" 13 13 0 "jj:" $'\uF126 '
}
