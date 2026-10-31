zline_segment_aws() {
  local -A opts=()
  _zline_std_opts "$@"

  local profile="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-$AWS_VAULT}}"
  local region="${AWS_REGION:-$AWS_DEFAULT_REGION}"

  local content="$profile"
  if [[ -n "$region" ]]; then
    if [[ -n "$content" ]]; then
      content="${content} (${region})"
    else
      content="$region"
    fi
  fi

  _zline_segment_emit "$content" 3 3 0 "aws:" $'\u2601 '
}
