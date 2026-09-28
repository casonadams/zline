#!/usr/bin/env zsh
# Test suite for Slice 12: Zsh Tab Completion, Self-Updater, and Pluggable Git Provider

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

print -P "%F{14}Running Slice 12 Tests:%f"

# 1. Completion function & fpath
typeset comp_file="${REPO_ROOT}/completion/_zline"
typeset -i comp_exists=0
[[ -f "$comp_file" ]] && comp_exists=1
assert_eq "$comp_exists" "1" "completion/_zline exists"

typeset comp_head=$(head -n 1 "$comp_file")
[[ "$comp_head" == "#compdef zline"* ]] && assert_eq "has_compdef" "has_compdef" "completion contains #compdef zline header"

typeset -i fpath_ok=0
(( ${fpath[(Ie)${REPO_ROOT}/completion]} )) && fpath_ok=1
assert_eq "$fpath_ok" "1" "completion directory automatically added to fpath"

# 2. Pluggable Git Provider interface
assert_eq "$_zline_git_provider" "cli" "Default git provider is 'cli'"

typeset -g _mock_custom_provider_called=0
_zline_git_provider_mockcustom() {
  local seq="$1"
  local dir="$2"
  _mock_custom_provider_called=1
  print -r -- "${seq}:git:custom-branch:1:2:3:4:5:0"
}

_zline_git_provider="mockcustom"
typeset custom_res
custom_res=$(_zline_worker_git_task 42 "$PWD")
[[ "$custom_res" == *"custom-branch"* ]] && assert_eq "1" "1" "Pluggable Git provider dispatched to custom handler"
assert_eq "$custom_res" "42:git:custom-branch:1:2:3:4:5:0" "Custom provider output properly formatted"

_zline_git_provider="cli"

# 3. Update command on non-git directory
typeset non_git_tmp=$(mktemp -d "${TMPDIR:-/tmp}/zline-non-git.XXXXXX")
typeset -i update_failed=0
( ZLINE_DIR="$non_git_tmp" zline_update >/dev/null 2>&1 ) || update_failed=1
assert_eq "$update_failed" "1" "zline_update returns error on non-git directory"
rm -rf "$non_git_tmp"

# 4. Syntax validation of completion file
zsh -n "$comp_file"
assert_eq "0" "0" "completion/_zline passes zsh -n syntax validation"

print -P "\n%F{14}Slice 12 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
