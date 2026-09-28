#!/usr/bin/env zsh
# Test suite for Slice 26: OS Distro Badging, Container Sandbox & Shell Nesting Depth

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

print -P "%F{14}Running Slice 26 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice26.XXXXXX")"
cd "$test_dir"

# 1. os segment
zline_segment_os
if [[ "$OSTYPE" == darwin* ]]; then
  assert_eq "$_zline_ret_fg" "15" "os segment detects darwin with color 15"
  zline_segment_os --text
  assert_eq "$_zline_ret_content" "mac" "os --text displays mac on darwin"
fi

# Test os with custom symbol and color
zline_segment_os --symbol "CUSTOM_OS:" --color 14
assert_eq "$_zline_ret_icon" "CUSTOM_OS:" "os honors custom --symbol override"
assert_eq "$_zline_ret_fg" "14" "os honors custom --color override"

# 2. container segment
zline_segment_container
assert_eq "$_zline_ret_content" "" "container is empty when not in sandbox"

WSL_DISTRO_NAME="Ubuntu-22.04"
zline_segment_container
assert_eq "$_zline_ret_content" "Ubuntu-22.04" "container detects \$WSL_DISTRO_NAME"
assert_eq "$_zline_ret_fg" "14" "container uses color 14"
unset WSL_DISTRO_NAME

SNAP="/snap/core/current"
zline_segment_container
assert_eq "$_zline_ret_content" "snap" "container detects \$SNAP"
unset SNAP

# 3. shlvl segment
SHLVL=1
zline_segment_shlvl
assert_eq "$_zline_ret_content" "" "shlvl empty when SHLVL < threshold (1 < 2)"

SHLVL=2
zline_segment_shlvl
assert_eq "$_zline_ret_content" "2" "shlvl displays 2 when SHLVL == 2"
assert_eq "$_zline_ret_fg" "11" "shlvl uses initial warning color 11"

SHLVL=3
zline_segment_shlvl
assert_eq "$_zline_ret_content" "3" "shlvl displays 3 when SHLVL == 3"
assert_eq "$_zline_ret_fg" "9" "shlvl applies deep warning color 9 at SHLVL >= 3"

SHLVL=2
zline_segment_shlvl --threshold 3
assert_eq "$_zline_ret_content" "" "shlvl honors custom --threshold"

unset SHLVL

# 4. Documentation completeness
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
assert_eq "$all_documented" "1" "All 48 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 26 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
