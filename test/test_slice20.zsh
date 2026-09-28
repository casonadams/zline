#!/usr/bin/env zsh
# Test suite for Slice 24: Long-Running Command Notifications, Bun & Deno Runtimes

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

print -P "%F{14}Running Slice 24 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice24.XXXXXX")"
cd "$test_dir"

# 1. bun segment
touch bun.lockb
zline_segment_bun
assert_eq "$_zline_ret_content" "bun" "bun detects bun.lockb"
assert_eq "$_zline_ret_fg" "15" "bun uses default color 15"
rm -f bun.lockb

print "bun 1.1.4" > .tool-versions
zline_segment_bun
assert_eq "$_zline_ret_content" "1.1.4" "bun segment reads .tool-versions"
rm -f .tool-versions

# 2. deno segment
touch deno.json
zline_segment_deno
assert_eq "$_zline_ret_content" "deno" "deno detects deno.json"
assert_eq "$_zline_ret_fg" "10" "deno uses default color 10"
rm -f deno.json

print "deno 1.41.0" > .tool-versions
zline_segment_deno
assert_eq "$_zline_ret_content" "1.41.0" "deno segment reads .tool-versions"
rm -f .tool-versions

# 3. zline notify CLI commands
typeset out
out="$(zline notify status)"
assert_eq "$out" "Notifications: disabled" "zline notify status initially disabled"

zline notify on 15 >/dev/null
assert_eq "$_zline_notify_enabled" "1" "zline notify on enables notifications"
assert_eq "$_zline_notify_threshold" "15" "zline notify on sets custom threshold"

out="$(zline notify status)"
assert_eq "$out" "Notifications: enabled (threshold: 15s)" "zline notify status shows enabled and threshold"

zline notify threshold 45 >/dev/null
assert_eq "$_zline_notify_threshold" "45" "zline notify threshold updates threshold"

zline notify off >/dev/null
assert_eq "$_zline_notify_enabled" "0" "zline notify off disables notifications"

# 4. _zline_notify_precmd emission
_zline_notify_enabled=1
_zline_notify_threshold=10
_zline_notify_last_cmd="npm test"
_zline_last_duration=12.5
_zline_last_exit_code=0

# Intercept stdout
exec 3>&1
typeset notify_output
notify_output="$(_zline_notify_precmd)"
exec 1>&3

# Test that notification output contains OSC 777 and OSC 9 escape sequences
typeset has_osc777=0
typeset has_osc9=0
[[ "$notify_output" == *$'\e]777;notify;'* ]] && has_osc777=1
[[ "$notify_output" == *$'\e]9;'* ]] && has_osc9=1
assert_eq "$has_osc777" "1" "Notification emits OSC 777 escape sequence"
assert_eq "$has_osc9" "1" "Notification emits OSC 9 escape sequence"

# Test no notification when below threshold
_zline_notify_last_cmd="ls"
_zline_last_duration=2.0
typeset below_thresh_output
below_thresh_output="$(_zline_notify_precmd)"
assert_eq "$below_thresh_output" "" "No notification emitted when duration < threshold"

_zline_notify_enabled=0

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
assert_eq "$all_documented" "1" "All 30 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 24 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
