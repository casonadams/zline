#!/usr/bin/env zsh
# Test suite for Slice 4: Transient Prompt & Modern Terminal Protocols

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"

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

print -P "%F{14}Running Slice 4 Tests:%f"

# 1. OSC 133 & OSC 7 Protocols
_zline_osc=1
_zline_osc_prompt_prefix
assert_eq "${REPLY[1,2]}" "%{" "OSC prompt prefix starts with zero-width %{"
assert_eq "${REPLY[-2,-1]}" "%}" "OSC prompt prefix ends with zero-width %}"
[[ "$REPLY" == *"133;A"* ]] && assert_eq "has_133_a" "has_133_a" "OSC prefix includes OSC 133;A prompt start"
[[ "$REPLY" == *"7;file://"* ]] && assert_eq "has_7" "has_7" "OSC prefix includes OSC 7 file URL"

_zline_osc_prompt_suffix
[[ "$REPLY" == *"133;B"* ]] && assert_eq "has_133_b" "has_133_b" "OSC suffix includes OSC 133;B command start"

# Disabling OSC
_zline_osc=0
_zline_osc_prompt_prefix
assert_eq "$REPLY" "" "Disabling OSC produces empty prefix"
_zline_osc_prompt_suffix
assert_eq "$REPLY" "" "Disabling OSC produces empty suffix"
_zline_osc=1

# 3. Transient Prompt
_zline_transient=1
_zline_transient_symbol="❯"
_zline_transient_color="10"
PROMPT="FULL_MULTILINE_PROMPT"
RPROMPT="FULL_RPROMPT"

_zline_transient_line_finish
assert_eq "$PROMPT" "%F{10}❯%f " "Transient line-finish collapses PROMPT to minimal symbol"
assert_eq "$RPROMPT" "" "Transient line-finish clears RPROMPT"

# Custom transient options
_zline_transient_symbol="#"
_zline_transient_color="11"
_zline_transient_line_finish
assert_eq "$PROMPT" "%F{11}#%f " "Custom transient symbol and color applied"

# Transient disabled
_zline_transient=0
PROMPT="ORIGINAL_PROMPT"
_zline_transient_line_finish
assert_eq "$PROMPT" "ORIGINAL_PROMPT" "Disabled transient prompt leaves PROMPT untouched"

# Line finish hook dispatching
typeset -g _received_line_finish=0
_test_line_finish_hook() {
  _received_line_finish=1
}
zline_hook add line_finish _test_line_finish_hook
_zline_transient=1
_zline_transient_line_finish
assert_eq "$_received_line_finish" "1" "line_finish hook dispatched on transient line finish"
_zline_transient=0

# 4. Vi-mode keymap select hook
typeset -g _received_keymap=""
_test_vi_hook() {
  _received_keymap="$1"
}

zline_hook add keymap_select _test_vi_hook
KEYMAP="vicmd"
_zline_vi_keymap_select
assert_eq "$_zline_vi_mode" "vicmd" "Vi-mode updates to vicmd on keymap select"
assert_eq "$_received_keymap" "vicmd" "Vi-mode keymap_select hook dispatched with vicmd"

KEYMAP="main"
_zline_vi_keymap_select
assert_eq "$_zline_vi_mode" "main" "Vi-mode updates to main on insert mode"
assert_eq "$_received_keymap" "main" "Vi-mode keymap_select hook dispatched with main"

print -P "\n%F{14}Slice 4 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
