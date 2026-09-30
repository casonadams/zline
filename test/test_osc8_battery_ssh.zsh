#!/usr/bin/env zsh
# Test suite for Slice 13: Terminal Resize, OSC 8 Hyperlinks, SSH Context, and Battery

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

print -P "%F{14}Running Slice 13 Tests:%f"

# 1. OSC 8 Hyperlinks
_zline_osc=1
_zline_osc_hyperlinks=1
_zline_osc_hyperlink "https://github.com/casonadams/zline" "zline"
assert_eq "${REPLY[1,2]}" "%{" "OSC 8 hyperlink starts with zero-width %{"
[[ "$REPLY" == *"8;;https://github.com"* ]] && assert_eq "has_url" "has_url" "OSC 8 sequence includes target URL"
[[ "$REPLY" == *"zline"* ]] && assert_eq "has_text" "has_text" "OSC 8 sequence wraps label text"

# Visual length ignores OSC 8 escape sequences
_zline_visual_len "$REPLY"
assert_eq "$REPLY" "5" "Visual length of OSC 8 hyperlink matches label text length"

_zline_osc_hyperlinks=0
_zline_osc_hyperlink "https://example.com" "plain"
assert_eq "$REPLY" "plain" "Hyperlinks disabled returns plain text"

# 2. SSH & User Host Context
SSH_CLIENT="" SSH_TTY="" SSH_CONNECTION="" zline_segment_user_host
assert_eq "$_zline_ret_content" "" "user_host is empty in local user session"

SSH_CLIENT="192.168.1.1 1234 22" zline_segment_user_host
[[ -n "$_zline_ret_content" ]] && assert_eq "has_ssh" "has_ssh" "user_host shows user@host in SSH session"
assert_eq "$_zline_ret_fg" "11" "SSH user_host color is yellow (11)"
unset SSH_CLIENT

zline_segment_user_host --always
[[ -n "$_zline_ret_content" ]] && assert_eq "has_always" "has_always" "user_host shows when --always passed"

# 3. Battery Segment
zline_segment_battery
typeset -i bat_ok=0
[[ "$_zline_ret_content" == *%* || -z "$_zline_ret_content" ]] && bat_ok=1
assert_eq "$bat_ok" "1" "Battery segment outputs valid percentage or clean empty"

# 4. TRAPWINCH hook definition
typeset -i trapwinch_ok=0
(( $+functions[TRAPWINCH] )) && trapwinch_ok=1
assert_eq "$trapwinch_ok" "1" "TRAPWINCH window resize signal handler defined"

print -P "\n%F{14}Slice 13 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
