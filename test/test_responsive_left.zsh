#!/usr/bin/env zsh
# Test suite: left prompt shrinks in stages to fit narrow terminals

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

# has <haystack> <needle> -> 1 when haystack contains needle
has() { [[ "$1" == *"$2"* ]] && REPLY=1 || REPLY=0 }

print -P "%F{14}Running Responsive Left Prompt Tests:%f"

typeset tmp_repo
tmp_repo="$(mktemp -d "${TMPDIR:-/tmp}/zline-rl.XXXXXX")"
mkdir -p "${tmp_repo}/.git" "${tmp_repo}/alpha/bravo/charlie"
print -r -- "ref: refs/heads/feature/a-very-long-branch-name" > "${tmp_repo}/.git/HEAD"
cd "${tmp_repo}/alpha/bravo/charlie"

zline style lean --ascii --no-osc
zline_left=( dir git 'text "LOWPRIO"' newline prompt_char )
zline_right=()
zline init

unset COLUMNS
zline_render
typeset full_top="${PROMPT%%$'\n'*}"
_zline_visual_len "$full_top"
typeset -i full_w=$REPLY
has "$full_top" "alpha/bravo/charlie"; typeset -i full_dir=$REPLY
has "$full_top" "LOWPRIO"; typeset -i full_low=$REPLY
assert_eq "$full_dir$full_low" "11" "unconstrained prompt keeps the full directory and every segment"

typeset -i c dir_short_at=0 branch_cut_at=0 drop_at=0 overflow=0
typeset t
for (( c = full_w + 1; c >= 24; c-- )); do
  COLUMNS=$c zline_render
  t="${PROMPT%%$'\n'*}"
  _zline_visual_len "$t"
  (( REPLY >= c )) && overflow=$c
  has "$t" "alpha/bravo/charlie"; (( dir_short_at == 0 && REPLY == 0 )) && dir_short_at=$c
  has "$t" "..."; (( branch_cut_at == 0 && REPLY == 1 )) && branch_cut_at=$c
  has "$t" "LOWPRIO"; (( drop_at == 0 && REPLY == 0 )) && drop_at=$c
done

assert_eq "$overflow" "0" "top line stays narrower than COLUMNS at every width down to 24"
assert_eq "$(( dir_short_at > 0 && dir_short_at > branch_cut_at ))" "1" "directory shrinks before the branch is truncated"
assert_eq "$(( branch_cut_at > 0 && branch_cut_at >= drop_at ))" "1" "branch is truncated before low-priority segments are dropped"
assert_eq "$(( drop_at > 0 ))" "1" "low-priority segment is eventually dropped"

COLUMNS=24 zline_render
t="${PROMPT%%$'\n'*}"
has "$t" "charlie"
assert_eq "$REPLY" "1" "directory survives when other segments are dropped"

COLUMNS=8 zline_render
typeset second="${PROMPT#*$'\n'}"
assert_eq "$(( ${#second} > 0 ))" "1" "prompt character line survives extreme narrowing"
unset COLUMNS

cd /
rm -rf "$tmp_repo"

print -P "\n%F{14}Responsive Left Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
