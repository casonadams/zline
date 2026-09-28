#!/usr/bin/env zsh
# Test suite for Slice 22: Shell Option Isolation and Hostile Environment Resilience

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

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

print -P "%F{14}Running Hostile Shell Options Tests:%f"

# 1. ksh_arrays resilience (0-based indexing)
typeset res_ksh
res_ksh=$(zsh -c "
  setopt ksh_arrays
  source '${REPO_ROOT}/zline.zsh'
  zline preset powerline --no-osc
  zline init
  zline_render
  [[ -n \"\$PROMPT\" ]] && print 'ok'
")
assert_eq "$res_ksh" "ok" "zline initializes and renders under setopt ksh_arrays"

# 2. sh_word_split resilience
typeset res_split
res_split=$(zsh -c "
  setopt sh_word_split
  source '${REPO_ROOT}/zline.zsh'
  zline preset lean --no-osc
  zline init
  zline_render
  [[ -n \"\$PROMPT\" ]] && print 'ok'
")
assert_eq "$res_split" "ok" "zline initializes and renders under setopt sh_word_split"

# 3. nounset resilience (aborts on unset variable)
typeset res_nounset
res_nounset=$(zsh -c "
  setopt nounset
  source '${REPO_ROOT}/zline.zsh'
  zline preset pure --no-osc
  zline init
  zline_render
  [[ -n \"\$PROMPT\" ]] && print 'ok'
")
assert_eq "$res_nounset" "ok" "zline initializes and renders under setopt nounset"

# 4. Combined hostile environment (ksh_arrays + sh_word_split + nounset)
typeset res_all
res_all=$(zsh -c "
  setopt ksh_arrays sh_word_split nounset
  source '${REPO_ROOT}/zline.zsh'
  zline preset rainbow --no-osc
  zline init
  zline_render
  [[ -n \"\$PROMPT\" ]] && print 'ok'
")
assert_eq "$res_all" "ok" "zline initializes and renders under all hostile options combined"

print -P "\n%F{14}Hostile Options Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
