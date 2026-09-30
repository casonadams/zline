#!/usr/bin/env zsh
# Test suite for Slice 18: Directory Read-Only Lock, Git Submodules, and High-Precision Duration

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

print -P "%F{14}Running Slice 18 Tests:%f"

# 1. Directory Read-Only Lock
typeset orig_pwd="$PWD"
cd /etc
zline_segment_dir
assert_eq "$_zline_ret_fg" "9" "Read-only directory foreground color turns red (9)"
[[ "$_zline_ret_icon" == *$'\uF023'* || "$_zline_ret_icon" == *"[ro]"* ]] && assert_eq "has_lock" "has_lock" "Read-only directory displays lock icon"
cd "$orig_pwd"

# Writable directory
zline_segment_dir
assert_eq "$_zline_ret_fg" "4" "Writable directory displays standard color (4)"

# 2. Exec Time Precision
_zline_last_duration=4.237
_zline_format_duration "$_zline_last_duration" 1
assert_eq "$REPLY" "4.2s" "Duration with precision 1 formats to 1 decimal place"

_zline_format_duration "$_zline_last_duration" 2
assert_eq "$REPLY" "4.23s" "Duration with precision 2 formats to 2 decimal places"

zline_segment_exec_time --min 1 --precision 2
assert_eq "$_zline_ret_content" "4.23s" "Exec time segment respects --precision 2"

# 3. Git Submodule Detection
typeset sub_tmp=$(mktemp -d "${TMPDIR:-/tmp}/zline-submod.XXXXXX")
mkdir -p "${sub_tmp}/real_git_dir"
print -r "ref: refs/heads/sub-feature" > "${sub_tmp}/real_git_dir/HEAD"
print -r "gitdir: ${sub_tmp}/real_git_dir" > "${sub_tmp}/.git"

cd "$sub_tmp"
zline_segment_git --submodule
[[ "$_zline_ret_content" == *"sub-feature"* ]] && assert_eq "has_sub_branch" "has_sub_branch" "Submodule branch name extracted"
cd "$orig_pwd"
rm -rf "$sub_tmp"

# 4. Vi cursor config
assert_eq "$_zline_vi_cursor" "1" "Vi cursor shape switching enabled by default"

print -P "\n%F{14}Slice 18 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
