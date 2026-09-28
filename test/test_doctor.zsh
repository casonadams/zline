#!/usr/bin/env zsh
# Test suite for zline doctor health diagnostics

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

print -P "%F{14}Running Doctor Tests:%f"

# 1. Doctor runs cleanly on standard installation
zline preset powerline --no-osc
zline init

doctor_output=$(zline doctor)
[[ "$doctor_output" == *"Everything is healthy"* ]] && assert_eq "healthy" "healthy" "zline doctor passes on standard setup"

# 2. Check individual check functions
_zline_doctor_warnings=0
_zline_doctor_errors=0
_zline_doctor_check_zsh
assert_eq "$_zline_doctor_errors" "0" "Zsh version check passes for current shell"

_zline_doctor_check_locale
assert_eq "$_zline_doctor_errors" "0" "Locale check passes without error"

_zline_doctor_check_cache
assert_eq "$_zline_doctor_errors" "0" "Cache directory check passes"

# 3. Warning on unregistered segment
_zline_compiled_left_names+=("totally_invalid_segment_xyz")
_zline_doctor_warnings=0
_zline_doctor_check_segments
assert_eq "$_zline_doctor_warnings" "1" "Unregistered segment generates doctor warning"
_zline_compiled_left_names[-1]=()

print -P "\n%F{14}Doctor Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
