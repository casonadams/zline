#!/usr/bin/env zsh
# Test suite for Slice 35: Expanded Frame Shapes & Connecting Line Styles

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

print -P "%F{14}Running Slice 35 Tests:%f"

# 1. Sharp frame shape
_zline_frame="left"
_zline_frame_shape="sharp"
_zline_compiled_left_names=( "prompt_char" )
_zline_compiled_left_args=( "" )

_zline_render_left
typeset has_sharp_corner=0
[[ "$REPLY" == *$'\u250C'* ]] && has_sharp_corner=1
assert_eq "$has_sharp_corner" "1" "sharp frame shape renders ┌ corner"

# 2. Double frame shape
_zline_frame_shape="double"
_zline_render_left
typeset has_double_corner=0
[[ "$REPLY" == *$'\u2554'* ]] && has_double_corner=1
assert_eq "$has_double_corner" "1" "double frame shape renders ╔ corner"

# 3. Rounded frame shape (default)
_zline_frame_shape="rounded"
_zline_render_left
typeset has_rounded_corner=0
[[ "$REPLY" == *$'\u256D'* ]] && has_rounded_corner=1
assert_eq "$has_rounded_corner" "1" "rounded frame shape renders ╭ corner"

# 4. Connecting line styles via CLI
zline style lean --connect dashed
assert_eq "$_zline_connect_char" "┄" "zline style --connect dashed sets ┄"

zline style lean --connect dotted
assert_eq "$_zline_connect_char" "┈" "zline style --connect dotted sets ┈"

zline style lean --connect solid
assert_eq "$_zline_connect_char" "─" "zline style --connect solid sets ─"

_zline_frame="none"
_zline_connect_char=""

print -P "\n%F{14}Slice 35 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
