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

  _zline_find_jj_root "$PWD" || true
  local jj_root="$REPLY"
  if [[ -z "$jj_root" ]]; then
    _zline_ret_content=""
    return 0
  fi

  local info="jj"
  _zline_ret_content="${info}"
  _zline_segment_finish 13 13 0 "jj:" $'\uF126 '
}
