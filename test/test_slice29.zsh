#!/usr/bin/env zsh
# Test suite for Slice 33: Advanced Directory Truncation Strategies

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

print -P "%F{14}Running Slice 33 Tests:%f"

typeset test_dir
typeset base_tmp="${TMPDIR:-/tmp}"
base_tmp="${base_tmp%/}"
test_dir="$(mktemp -d "${base_tmp}/zline_test_slice33.XXXXXX")"
mkdir -p "${test_dir}/deep/nested/sub/project/src"

# 1. dir --last N formatting
local -a empty_aliases=()
_zline_dir_format_path "${test_dir}/deep/nested/sub/project/src" 0 1 "none" 2 empty_aliases
assert_eq "$REPLY" ".../project/src" "dir --last 2 truncates leading directories to ellipsis"

_zline_dir_format_path "${test_dir}/deep/nested/sub/project/src" 0 1 "none" 1 empty_aliases
assert_eq "$REPLY" ".../src" "dir --last 1 truncates all but current directory"

_zline_dir_format_path "${test_dir}/deep/nested/sub/project/src" 0 1 "none" 50 empty_aliases
assert_eq "$REPLY" "${test_dir}/deep/nested/sub/project/src" "dir --last does not truncate when depth < N"

# 2. dir --anchor project
touch "${test_dir}/deep/nested/sub/project/package.json"
_zline_find_project_root "${test_dir}/deep/nested/sub/project/src"
assert_eq "$REPLY" "${test_dir}/deep/nested/sub/project" "find_project_root identifies package.json"
rm -f "${test_dir}/deep/nested/sub/project/package.json"
touch "${test_dir}/deep/nested/sub/project/Gemfile"
_zline_find_project_root "${test_dir}/deep/nested/sub/project/src"
assert_eq "$REPLY" "${test_dir}/deep/nested/sub/project" "find_project_root identifies Gemfile"

rm -f "${test_dir}/deep/nested/sub/project/Gemfile"
touch "${test_dir}/deep/nested/sub/project/build.zig"
_zline_find_project_root "${test_dir}/deep/nested/sub/project/src"
assert_eq "$REPLY" "${test_dir}/deep/nested/sub/project" "find_project_root identifies build.zig"

rm -f "${test_dir}/deep/nested/sub/project/build.zig"
mkdir -p "${test_dir}/deep/nested/sub/project/.jj"
_zline_find_project_root "${test_dir}/deep/nested/sub/project/src"
assert_eq "$REPLY" "${test_dir}/deep/nested/sub/project" "find_project_root identifies .jj"

rm -rf "$test_dir"

print -P "\n%F{14}Slice 33 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
