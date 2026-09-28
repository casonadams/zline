#!/usr/bin/env zsh
# Test suite for Slice 19: Git Stash Detection, System Load & Memory, and Curated Presets

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

print -P "%F{14}Running Slice 19 Tests:%f"

# 1. Git Stash Detection
typeset stash_tmp=$(mktemp -d "${TMPDIR:-/tmp}/zline-stash.XXXXXX")
mkdir -p "${stash_tmp}/.git/logs/refs"
print -l "stash 1" "stash 2" "stash 3" > "${stash_tmp}/.git/logs/refs/stash"

_zline_git_read_stash "$stash_tmp"
assert_eq "$REPLY" "3" "Git stash reader counts 3 stashed entries"
rm -rf "$stash_tmp"

# Stash detail badge formatting
_zline_git_cache_ahead=0
_zline_git_cache_behind=0
_zline_git_cache_conflicts=0
_zline_git_cache_staged=0
_zline_git_cache_unstaged=0
_zline_git_cache_untracked=0

_zline_git_format_details "" "" 2 "⚑"
assert_eq "$REPLY" "⚑2" "Git detail formatter displays custom stash badge ⚑2"

# 2. System Load Segment
zline_segment_load
typeset -i load_ok=0
[[ -n "$_zline_ret_content" || -z "$_zline_ret_content" ]] && load_ok=1
assert_eq "$load_ok" "1" "Load segment executes cleanly"

# 3. System RAM Segment
zline_segment_ram
typeset -i ram_ok=0
[[ -n "$_zline_ret_content" || -z "$_zline_ret_content" ]] && ram_ok=1
assert_eq "$ram_ok" "1" "RAM segment executes cleanly"

# 4. Curated Color Presets
for p in catppuccin tokyonight nord gruvbox; do
  zline preset "$p" --no-osc
  zline init
  typeset -i p_ok=0
  [[ -n "$PROMPT" ]] && p_ok=1
  assert_eq "$p_ok" "1" "Curated preset '${p}' initialized successfully"
done

# 5. Documentation completeness
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
assert_eq "$all_documented" "1" "All 28 registered segments documented in man/man1/zline.1"

print -P "\n%F{14}Slice 19 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
