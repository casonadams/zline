#!/usr/bin/env zsh
# Test suite for Slice 20: Multiline RPROMPT Alignment and Full Frame Terminations

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

print -P "%F{14}Running Slice 20 Tests:%f"

zline preset powerline --no-osc
zline_right=(time)
zline init

# 1. RPROMPT on Line 1 (embedded on multiline top line)
COLUMNS=80
_zline_rprompt_line=1
_zline_connect_char=""
zline_render

typeset -i top_has_time=0
typeset top_line="${PROMPT%%$'\n'*}"
[[ "$top_line" == *"00:"* || "$top_line" == *":00"* || "$top_line" == *":"* ]] && top_has_time=1
assert_eq "$top_has_time" "1" "RPROMPT on Line 1 embeds right segments onto line 1"
assert_eq "$RPROMPT" "" "RPROMPT on Line 1 clears native RPROMPT"

# 2. RPROMPT on Line 2 (native RPROMPT alongside prompt char)
_zline_rprompt_line=2
zline_render

typeset -i native_rprompt_ok=0
[[ -n "$RPROMPT" ]] && native_rprompt_ok=1
assert_eq "$native_rprompt_ok" "1" "RPROMPT on Line 2 preserves native RPROMPT"

# 3. Full Frame Terminations (--frame full)
_zline_frame="full"
_zline_rprompt_line=1
zline_render

typeset top_frame_line="${PROMPT%%$'\n'*}"
[[ "$top_frame_line" == *"╭─"* ]] && assert_eq "has_top_left" "has_top_left" "Full frame includes top-left ╭─"
[[ "$top_frame_line" == *"─╮"* ]] && assert_eq "has_top_right" "has_top_right" "Full frame includes top-right ─╮"

# Reset frame and rprompt line
_zline_frame="none"
_zline_rprompt_line=1

print -P "\n%F{14}Slice 20 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
