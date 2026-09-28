#!/usr/bin/env zsh
# Test suite for Slice 17: Framework Compatibility, Profiling, and Preset Inspection

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

print -P "%F{14}Running Framework Tests:%f"

# 1. Oh-My-Zsh theme bridge (zline.zsh-theme)
typeset omz_res
omz_res=$(zsh -c "source '${REPO_ROOT}/zline.zsh-theme' >/dev/null 2>&1 && [[ -n \"\$PROMPT\" ]] && print 'ok'")
assert_eq "$omz_res" "ok" "Oh-My-Zsh theme bridge (zline.zsh-theme) initializes cleanly"

# 2. Plugin manager loader (zline.plugin.zsh)
typeset plugin_res
plugin_res=$(zsh -c "source '${REPO_ROOT}/zline.plugin.zsh' && zline version >/dev/null && print 'ok'")
assert_eq "$plugin_res" "ok" "Plugin manager entry (zline.plugin.zsh) loads zline CLI"

# 3. Preset inspection commands
source "${REPO_ROOT}/zline.zsh"

typeset list_out
list_out=$(zline preset list)
[[ "$list_out" == *"powerline"* ]] && assert_eq "has_pw" "has_pw" "zline preset list includes powerline"
[[ "$list_out" == *"lean"* ]] && assert_eq "has_lean" "has_lean" "zline preset list includes lean"

typeset show_out
show_out=$(zline preset show powerline)
[[ "$show_out" == *'_zline_style="powerline"'* ]] && assert_eq "has_pw_style" "has_pw_style" "zline preset show displays configuration"

# 4. Per-segment micro-profiling
zline preset powerline --no-osc
zline init
typeset prof_out
prof_out=$(zline bench --profile 50)
[[ "$prof_out" == *"Micro-Profile"* ]] && assert_eq "has_profile" "has_profile" "zline bench --profile executes cleanly"
[[ "$prof_out" == *"dir"* && "$prof_out" == *"git"* ]] && assert_eq "has_segs" "has_segs" "zline bench --profile measures individual segments"

print -P "\n%F{14}Framework Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
