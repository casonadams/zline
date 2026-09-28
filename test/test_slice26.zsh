#!/usr/bin/env zsh
# Test suite for Slice 30: C/C++ Build Tooling (CMake) & Final Release Polish

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

print -P "%F{14}Running Slice 30 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice30.XXXXXX")"
cd "$test_dir"

# 1. cmake segment
cat << 'EOF' > CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(SuperEngine LANGUAGES C CXX)
add_executable(app main.cpp)
EOF

zline_segment_cmake
assert_eq "$_zline_ret_content" "SuperEngine" "cmake extracts project name from CMakeLists.txt"
assert_eq "$_zline_ret_fg" "4" "cmake uses default color 4"
rm -f CMakeLists.txt

touch CMakeCache.txt
zline_segment_cmake
assert_eq "$_zline_ret_content" "cmake" "cmake detects CMakeCache.txt fallback"
rm -f CMakeCache.txt

# 2. Documentation completeness
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
assert_eq "$all_documented" "1" "All 48 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 30 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
