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
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  _zline_find_jj_root "$PWD" || true
  local jj_root="$REPLY"
  if [[ -z "$jj_root" ]]; then
    _zline_ret_content=""
    return 0
  fi

  local info="jj"
  _zline_ret_content="${info}"
  _zline_ret_fg="${opts[--color]:-13}"
  _zline_ret_bg="${opts[--bg]:-13}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="jj:"
  else
    _zline_ret_icon=$'\uF126 '
  fi
}
