zline_segment_bazel() {
  emulate -L zsh
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local content=""
  if _zline_find_up "MODULE.bazel" "WORKSPACE" "BUILD.bazel" "BUILD" ".bazelrc"; then
    content="bazel"
  fi

  if [[ -z "$content" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-10}"
  _zline_ret_bg="${opts[--bg]:-10}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="bzl:"
  else
    _zline_ret_icon=$'\uF1B2 '
  fi
}
