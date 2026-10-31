zline_segment_jobs() {
  local -A opts=()
  _zline_std_opts "$@"

  local -i count=${#jobstates}
  if (( count == 0 )); then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${count}"
  _zline_segment_finish 11 3 0 "jobs:" $'\u2726 '
}
