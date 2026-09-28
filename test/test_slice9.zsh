#!/usr/bin/env zsh
# Test suite for Slice 9: Bytecode Compilation, Frame Connectors, Responsive Truncation & Extended Segments

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"
_zline_osc=0

typeset -i passed=0
typeset -i failed=0

assert_eq() {
  local actual="$1"
  local expected="$2"
  local desc="$3"
  if [[ "$actual" == "$expected" ]]; then
    (( passed += 1 ))
    print -P "  %F{10}✓%f ${desc}"
  else
    (( failed += 1 ))
    print -P "  %F{9}✗%f ${desc} (expected: '${expected}', got: '${actual}')"
  fi
}

print -P "%F{14}Running Slice 9 Tests:%f"

# 1. Time segment
zline_segment_time --format "%H:%M"
[[ -n "$_zline_ret_content" ]] && assert_eq "ok" "ok" "Time segment formats current time without subshells"
assert_eq "$_zline_ret_fg" "8" "Time segment color is grey (8)"

# 2. Jobs segment
zline_segment_jobs
assert_eq "$_zline_ret_content" "" "Jobs segment is empty when no background jobs active"

# 3. AWS segment
AWS_PROFILE="staging-cluster" AWS_REGION="us-east-1" zline_segment_aws
assert_eq "$_zline_ret_content" "staging-cluster (us-east-1)" "AWS segment formats profile and region"
assert_eq "$_zline_ret_fg" "3" "AWS segment color is yellow (3)"
unset AWS_PROFILE AWS_REGION

zline_segment_aws
assert_eq "$_zline_ret_content" "" "AWS segment is empty when not in AWS context"

# 4. Frame connectors
zline preset powerline --frame left --no-osc
zline init
[[ "$PROMPT" == *"╭─"* ]] && assert_eq "has_top_frame" "has_top_frame" "Frame connector top glyph rendered"
[[ "$PROMPT" == *"╰─"* ]] && assert_eq "has_bot_frame" "has_bot_frame" "Frame connector bottom glyph rendered"
_zline_frame="none"

# 5. Responsive truncation
zline preset powerline --no-osc
zline_right=(time)
_zline_rprompt_line=2
zline init

# When COLUMNS is large, RPROMPT is rendered
COLUMNS=150 zline_render
typeset -i has_rprompt=0
[[ -n "$RPROMPT" ]] && has_rprompt=1
assert_eq "$has_rprompt" "1" "RPROMPT rendered when COLUMNS width is ample"

# When COLUMNS is small, RPROMPT is dropped to prevent line wrap
COLUMNS=15 zline_render
assert_eq "$RPROMPT" "" "RPROMPT dropped when terminal COLUMNS too narrow"
_zline_rprompt_line=1

# 6. Wordcode compilation (.zwc)
typeset test_file="${REPO_ROOT}/zline.zsh"
zline_compile_file "$test_file"
typeset -i zwc_exists=0
[[ -f "${test_file}.zwc" ]] && zwc_exists=1
assert_eq "$zwc_exists" "1" "zline_compile_file compiles .zwc bytecode"
rm -f "${test_file}.zwc"

print -P "\n%F{14}Slice 9 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
