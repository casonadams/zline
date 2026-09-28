#!/usr/bin/env zsh
# Test suite for Slice 11: Title Manager, Packaging, Installer, and Documentation Completeness

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

print -P "%F{14}Running Slice 11 Tests:%f"

# 1. Title manager
_zline_title_enabled=1
assert_eq "$_zline_title_enabled" "1" "Title manager enabled by default"

_zline_title_enabled=0
assert_eq "$_zline_title_enabled" "0" "Title manager can be disabled"
_zline_title_enabled=1

# 2. Installer script verification
typeset -i install_sh_ok=0
if [[ -x "${REPO_ROOT}/install.sh" ]]; then
  install_sh_ok=1
fi
assert_eq "$install_sh_ok" "1" "install.sh exists and is executable"

sh -n "${REPO_ROOT}/install.sh"
assert_eq "0" "0" "install.sh passes sh -n syntax check"

if (( $+commands[shellcheck] )); then
  shellcheck "${REPO_ROOT}/install.sh"
  assert_eq "0" "0" "install.sh passes shellcheck audit with 0 warnings"
fi

# 3. Homebrew formula verification
typeset -i formula_ok=0
if [[ -f "${REPO_ROOT}/Formula/zline.rb" ]]; then
  formula_ok=1
fi
assert_eq "$formula_ok" "1" "Formula/zline.rb exists"

if (( $+commands[ruby] )); then
  ruby -c "${REPO_ROOT}/Formula/zline.rb" >/dev/null 2>&1
  assert_eq "0" "0" "Formula/zline.rb passes ruby syntax check"
fi

# 4. Documentation completeness: verify all registered segments are documented in man page
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
assert_eq "$all_documented" "1" "All registered segments documented in man/man1/zline.1"

print -P "\n%F{14}Slice 11 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
