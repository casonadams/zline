zline_segment_bazel() {
  emulate -L zsh
  local -A opts=()
  _zline_std_opts "$@"

  local content=""
  if _zline_find_up "MODULE.bazel" "WORKSPACE" "BUILD.bazel" "BUILD" ".bazelrc"; then
    content="bazel"
  fi

  _zline_segment_emit "$content" 10 10 0 "bzl:" $'\uF1B2 '
}
