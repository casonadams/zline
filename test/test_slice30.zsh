#!/usr/bin/env zsh
# Test suite for Slice 34: Responsive Auto-Truncation & Collision Prevention

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

print -P "%F{14}Running Slice 34 Tests:%f"

zline_left=( 'text "VERY_LONG_LEFT_PROMPT_STRING"' )
zline_right=( 'text "VERY_LONG_RIGHT_PROMPT_STRING"' )
zline style lean
zline init

# Wide terminal: both left and right should render
COLUMNS=160
zline_render
typeset has_rprompt=0
[[ -n "$RPROMPT" ]] && has_rprompt=1
assert_eq "$has_rprompt" "1" "right prompt renders on wide terminal (COLUMNS=160)"

# Narrow terminal: right prompt should be dropped to prevent collision
COLUMNS=30
zline_render
assert_eq "$RPROMPT" "" "right prompt dropped on narrow terminal (COLUMNS=30)"

unset COLUMNS

print -P "\n%F{14}Slice 34 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
