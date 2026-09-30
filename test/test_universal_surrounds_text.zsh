#!/usr/bin/env zsh
# Test suite for Slice 31: Universal Surrounds & Built-in Text Segment

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

print -P "%F{14}Running Slice 31 Tests:%f"

# 1. text segment basic
zline_segment_text "PRODUCTION"
assert_eq "$_zline_ret_content" "PRODUCTION" "text segment renders static string"
assert_eq "$_zline_ret_fg" "7" "text segment uses default color 7"

# 2. text segment with variables
MY_CLUSTER="k8s-prod-us-east"
zline_segment_text '$MY_CLUSTER'
assert_eq "$_zline_ret_content" "k8s-prod-us-east" "text segment evaluates parameter expansion"
unset MY_CLUSTER

# 3. Universal prefix and suffix
my_test_formatter() {
  REPLY="<<${1}>>"
}

zline_left=( 'text "FOO" --prefix "[" --suffix "]"' )
zline_right=()
zline style lean
zline init

zline_render
typeset clean_p="${PROMPT//\%F\{*\}/}"
clean_p="${clean_p//\%f/}"
assert_eq "$clean_p" "[FOO] " "universal prefix and suffix wrap segment"

# 4. Universal format function
zline_left=( 'text "BAR" --format my_test_formatter' )
zline init
zline_render
typeset clean_p2="${PROMPT//\%F\{*\}/}"
clean_p2="${clean_p2//\%f/}"
assert_eq "$clean_p2" "<<BAR>> " "universal format function processes segment"

# 5. Documentation completeness
typeset man_content
man_content="$(< "${REPO_ROOT}/man/man1/zline.1")"
typeset -i all_documented=1
local seg
for seg in "${(k)_zline_registered_segments[@]}"; do
  [[ "$seg" == "newline" ]] && continue
  if [[ "$man_content" != *".B $seg"* ]]; then
    all_documented=0
    print -P "  %F{9}Segment missing in man page:%f $seg"
  fi
done
assert_eq "$all_documented" "1" "All 58 registered segments documented in man/man1/zline.1"

print -P "\n%F{14}Slice 31 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
