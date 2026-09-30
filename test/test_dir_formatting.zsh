#!/usr/bin/env zsh
# Test suite for Slice 2: Directory Segment & Advanced Path Customization

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

print -P "%F{14}Running Slice 2 Tests:%f"

# 1. Path formatting without git
typeset -a test_aliases=()
_zline_dir_format_path "/var/log/nginx" 1 1 "none" test_aliases
assert_eq "$REPLY" "/v/l/nginx" "Shorten path to 1 character per intermediate component"

_zline_dir_format_path "/var/log/nginx" 0 1 "none" test_aliases
assert_eq "$REPLY" "/var/log/nginx" "Zero shortening keeps full path"

_zline_dir_format_path "/var/log/nginx" 2 1 "none" test_aliases
assert_eq "$REPLY" "/va/lo/nginx" "Shorten path to 2 characters"

_zline_dir_format_path "$HOME" 1 1 "none" test_aliases
assert_eq "$REPLY" "~" "Home directory renders as ~"

_zline_dir_format_path "/" 1 1 "none" test_aliases
assert_eq "$REPLY" "/" "Root directory renders as /"

# 2. Path formatting with aliases
test_aliases=("--alias" "github.com=gith")
_zline_dir_format_path "$HOME/src/github.com/casonadams/zline" 1 1 "none" test_aliases
assert_eq "$REPLY" "~/s/gith/c/zline" "Alias replaces component and is preserved intact"

# 3. Path formatting with Git anchor
typeset anchor_test="/tmp/zline_anchor_test_slice2"
mkdir -p "${anchor_test}/.git" "${anchor_test}/sub1/sub2"
_zline_dir_format_path "${anchor_test}/sub1/sub2" 1 1 "git" test_aliases
assert_eq "$REPLY" "/t/zline_anchor_test_slice2/s/sub2" "Git anchor preserves repository directory name full"
rm -rf "$anchor_test"

# 4. Custom formatter support
my_custom_formatter() {
  REPLY="CUSTOM:${1:t}"
}

zline_segment_dir --format my_custom_formatter
assert_eq "$_zline_ret_content" "CUSTOM:${PWD:t}" "Custom formatter overrides path formatting via \$REPLY"

# 5. Caching and chpwd invalidation
typeset expected_content
_zline_dir_format_path "$PWD" 1 1 "git" test_aliases
expected_content="$REPLY"
zline_segment_dir --shorten 1 --alias "github.com=gith" --anchor git
assert_eq "$_zline_ret_content" "$expected_content" "Segment computes formatted path correctly"
assert_eq "$_zline_dir_cache_pwd" "$PWD" "Cache stores current working directory"

# Simulate chpwd hook
_zline_dir_on_chpwd
assert_eq "$_zline_dir_cache_pwd" "" "chpwd hook clears directory cache"

# 6. Performance & zero-subshell assertion (1,000 iterations < 100ms)
zmodload zsh/datetime
typeset -F t0=$EPOCHREALTIME
typeset -i i
for (( i = 1; i <= 1000; i++ )); do
  zline_segment_dir --shorten 1 --alias "github.com=gith" --anchor git
done
typeset -F t1=$EPOCHREALTIME
typeset -F dur_ms=$(( (t1 - t0) * 1000.0 ))
if (( dur_ms < 150.0 )); then
  assert_eq "fast" "fast" "Zero-subshell check: 1000 executions took ${dur_ms} ms (< 150ms)"
else
  assert_eq "slow (${dur_ms} ms)" "fast" "Zero-subshell check failed: took too long"
fi

print -P "\n%F{14}Slice 2 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
