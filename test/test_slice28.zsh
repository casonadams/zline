#!/usr/bin/env zsh
# Test suite for Slice 32: Granular Git Status Styling & Custom Indicators

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

print -P "%F{14}Running Slice 32 Tests:%f"

# Set up mock git cache state
_zline_git_cache_valid=1
_zline_git_cache_staged=3
_zline_git_cache_unstaged=2
_zline_git_cache_untracked=1
_zline_git_cache_conflicts=0
_zline_git_cache_ahead=4
_zline_git_cache_behind=0

_zline_git_format_details "^" "v" 0 "*" "+" "!" "?" "x"
assert_eq "$REPLY" "+3 !2 ?1 ^4" "default git status formatting"

# Custom granular icons
_zline_git_format_details "▲" "▼" 0 "*" "●" "✚" "…" "✖"
assert_eq "$REPLY" "●3 ✚2 …1 ▲4" "custom granular git status icons"

# Conflicts formatting
_zline_git_cache_conflicts=1
_zline_git_format_details "▲" "▼" 0 "*" "●" "✚" "…" "✖"
assert_eq "$REPLY" "✖1 ●3 ✚2 …1 ▲4" "custom conflict icon"

# Stash icon formatting
_zline_git_format_details "▲" "▼" 2 "★" "●" "✚" "…" "✖"
assert_eq "$REPLY" "✖1 ●3 ✚2 …1 ▲4 ★2" "custom stash icon"

# Clean up mock state
unset _zline_git_cache_valid _zline_git_cache_staged _zline_git_cache_unstaged \
  _zline_git_cache_untracked _zline_git_cache_conflicts _zline_git_cache_ahead _zline_git_cache_behind

print -P "\n%F{14}Slice 32 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
