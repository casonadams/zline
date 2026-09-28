#!/usr/bin/env zsh
# Test suite for zline configure generation

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

print -P "%F{14}Running Configure Tests:%f"

typeset cfg_tmp=$(mktemp "${TMPDIR:-/tmp}/zline-test-cfg.XXXXXX")

# 1. Default Powerline generation
zline configure --style powerline --transient --shorten 1 --anchor git --out "$cfg_tmp"
typeset -i cfg_exists=0
[[ -s "$cfg_tmp" ]] && cfg_exists=1
assert_eq "$cfg_exists" "1" "Generated config file is created and non-empty"

typeset content=$(< "$cfg_tmp")
[[ "$content" == *"zline preset powerline --transient"* ]] && assert_eq "has_preset" "has_preset" "Config contains preset powerline"
[[ "$content" == *"--shorten 1 --anchor git"* ]] && assert_eq "has_anchor" "has_anchor" "Config contains shorten and anchor options"

# 2. Syntax check of generated file
zsh -n "$cfg_tmp"
assert_eq "0" "0" "Generated config file passes zsh -n syntax validation"

# 3. Lean style without transient
zline configure --style lean --no-transient --shorten 0 --anchor none --out "$cfg_tmp"
content=$(< "$cfg_tmp")
[[ "$content" == *"zline preset lean"* ]] && assert_eq "has_lean" "has_lean" "Config contains preset lean"
[[ "$content" != *"--transient"* ]] && assert_eq "no_trans" "no_trans" "Config omits --transient when disabled"

# 4. Source the generated configuration in clean subshell
zsh -c "source '${REPO_ROOT}/zline.zsh'; source '${cfg_tmp}'; [[ -n \"\$PROMPT\" ]]"
assert_eq "0" "0" "Generated configuration sources and initializes cleanly"

# 5. ASCII mode configuration
zline configure --style pure --ascii --out "$cfg_tmp"
content=$(< "$cfg_tmp")
[[ "$content" == *"zline preset pure"* && "$content" == *"--ascii"* ]] && assert_eq "has_ascii" "has_ascii" "Config contains --ascii flag when specified"

rm -f "$cfg_tmp"

print -P "\n%F{14}Configure Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
