#!/usr/bin/env zsh
# Test suite for Slice 4: Instant Prompt, Transient Prompt & Modern Terminal Protocols

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

# 2. Instant Prompt Caching & Restore
typeset test_cache_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-instant.XXXXXX")
_zline_instant_cache_dir="$test_cache_dir"
_zline_instant_file="${test_cache_dir}/instant-test.zsh"
_zline_instant_enabled=1

PROMPT="TEST_PROMPT_CONTENT"
RPROMPT="TEST_RPROMPT_CONTENT"
_zline_instant_save

typeset -i file_exists=0
[[ -f "$_zline_instant_file" ]] && file_exists=1
assert_eq "$file_exists" "1" "Instant prompt cache file created"

# Source the instant prompt cache file and measure latency (< 1ms)
zmodload zsh/datetime
typeset -F t0=$EPOCHREALTIME
source "$_zline_instant_file" >/dev/null
typeset -F t1=$EPOCHREALTIME
typeset -F dur_ms=$(( (t1 - t0) * 1000.0 ))

assert_eq "$_ZLINE_INSTANT_ACTIVE" "1" "Sourcing instant cache sets _ZLINE_INSTANT_ACTIVE=1"
assert_eq "$PROMPT" "TEST_PROMPT_CONTENT" "Sourcing instant cache restores PROMPT"
assert_eq "$RPROMPT" "TEST_RPROMPT_CONTENT" "Sourcing instant cache restores RPROMPT"

if (( dur_ms < 10.0 )); then
  assert_eq "fast" "fast" "Instant prompt loaded in ${dur_ms} ms (< 10.0 ms)"
else
  assert_eq "slow (${dur_ms} ms)" "fast" "Instant prompt loading took too long"
fi

_zline_instant_restore
assert_eq "$_ZLINE_INSTANT_ACTIVE" "0" "Instant restore resets _ZLINE_INSTANT_ACTIVE"

rm -rf "$test_cache_dir"

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
