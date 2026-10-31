zline_segment_jobs() {
  local -A opts=()
  _zline_std_opts "$@"

  local -i count=${#jobstates}
  _zline_segment_emit "${count:#0}" 11 3 0 "jobs:" $'\u2726 '
}
