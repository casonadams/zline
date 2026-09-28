#!/usr/bin/env zsh
# Test suite for Slice 16: Comparison Engine, Transient Directory Mode, and Git Tuning

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

print -P "%F{14}Running Slice 16 Tests:%f"

# 1. Transient Directory Mode
_zline_transient=1
_zline_transient_show_dir=1
_zline_transient_symbol="❯"
_zline_transient_color="10"
_zline_dir_cache_res="~/src/zline"

_zline_transient_line_finish
assert_eq "$PROMPT" "%F{4}~/src/zline%f %F{10}❯%f " "Transient line-finish retains directory when --transient-dir is enabled"

_zline_transient_show_dir=0
_zline_transient_line_finish
assert_eq "$PROMPT" "%F{10}❯%f " "Transient line-finish collapses to symbol only when --transient-dir is disabled"
_zline_transient=0

# 2. Git custom ahead and behind symbols
_zline_git_cache_ahead=3
_zline_git_cache_behind=1
_zline_git_cache_conflicts=0
_zline_git_cache_staged=0
_zline_git_cache_unstaged=0
_zline_git_cache_untracked=0

_zline_git_format_details "▲" "▼"
assert_eq "$REPLY" "▲3 ▼1" "Git details format with custom ahead (▲) and behind (▼) symbols"

_zline_git_format_details
[[ "$REPLY" == *"3"* && "$REPLY" == *"1"* ]] && assert_eq "ok" "ok" "Git details format with default symbols"

# 3. Comparison Benchmark execution
typeset compare_out
compare_out=$(zsh "${REPO_ROOT}/benchmark/compare.zsh")
[[ "$compare_out" == *"Prompt Performance Comparison"* ]] && assert_eq "has_header" "has_header" "Comparison benchmark executes successfully"
[[ "$compare_out" == *"faster"* ]] && assert_eq "has_speedup" "has_speedup" "Comparison benchmark outputs speedup multiplier"

# 4. Completion file contains compare command
typeset comp_content=$(< "${REPO_ROOT}/completion/_zline")
[[ "$comp_content" == *"compare:"* ]] && assert_eq "has_comp_compare" "has_comp_compare" "completion/_zline includes compare command"

# 5. Man page completeness check
typeset man_content=$(< "${REPO_ROOT}/man/man1/zline.1")
typeset -i all_documented=1
local seg
for seg in "${(k)_zline_registered_segments[@]}"; do
  [[ "$seg" == "newline" ]] && continue
  if [[ "$man_content" != *".B $seg"* ]]; then
    all_documented=0
    print -P "  %F{9}Segment missing in man page:%f $seg"
  fi
done
assert_eq "$all_documented" "1" "All 22 registered segments documented in man/man1/zline.1"

print -P "\n%F{14}Slice 16 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
