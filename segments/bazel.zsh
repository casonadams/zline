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
  _zline_segment_finish 10 10 0 "bzl:" $'\uF1B2 '
}
