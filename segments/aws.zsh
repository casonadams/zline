zline_segment_aws() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local profile="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-$AWS_VAULT}}"
  local region="${AWS_REGION:-$AWS_DEFAULT_REGION}"

  if [[ -z "$profile" && -z "$region" ]]; then
    _zline_ret_content=""
    return 0
  fi

  local content="$profile"
  if [[ -n "$region" ]]; then
    if [[ -n "$content" ]]; then
      content="${content} (${region})"
    else
      content="$region"
    fi
  fi

  _zline_ret_content="${content}"
  _zline_segment_finish 3 3 0 "aws:" $'\u2601 '
}
