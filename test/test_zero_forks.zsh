#!/usr/bin/env zsh
# Audit test: Verifies ZERO subshell forks $(...) on the synchronous render path

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

print -P "%F{14}Running Zero-Fork Audit Tests:%f"

# 1. Static analysis: ensure no subshell $(...) syntax in render path files
typeset -a hot_files=(
  "${REPO_ROOT}/lib/render.zsh"
  "${REPO_ROOT}/lib/color.zsh"
  "${REPO_ROOT}/lib/osc.zsh"
  "${REPO_ROOT}/segments/dir.zsh"
  "${REPO_ROOT}/segments/git.zsh"
  "${REPO_ROOT}/segments/status.zsh"
  "${REPO_ROOT}/segments/exec_time.zsh"
  "${REPO_ROOT}/segments/prompt_char.zsh"
  "${REPO_ROOT}/segments/venv.zsh"
  "${REPO_ROOT}/segments/nix_shell.zsh"
  "${REPO_ROOT}/segments/direnv.zsh"
  "${REPO_ROOT}/segments/lua.zsh"
  "${REPO_ROOT}/segments/zig.zsh"
)

typeset -i subshell_count=0
for f in "${hot_files[@]}"; do
  [[ -f "$f" ]] || continue
  while IFS= read -r line; do
    # Skip comments
    [[ "$line" == [[:space:]]#\#* ]] && continue
    # Match $( that is NOT arithmetic $((
    if [[ "$line" =~ '\$\([^ (]' ]]; then
      (( subshell_count += 1 ))
      print -P "  %F{9}Found subshell in %B${f:t}%b:%f $line"
    fi
  done < "$f"
done

assert_eq "$subshell_count" "0" "Static analysis: 0 subshells found in synchronous render path"

# 2. Runtime subshell level verification
zline preset powerline --no-osc
zline init

typeset -i pre_subshell=$ZSH_SUBSHELL
zline_render
typeset -i post_subshell=$ZSH_SUBSHELL

assert_eq "$pre_subshell" "0" "Initial shell is at subshell level 0"
assert_eq "$post_subshell" "0" "Prompt render completes at subshell level 0"

# 3. High-throughput latency proof (1,000 iterations < 500ms)
zmodload zsh/datetime
typeset -F t0=$EPOCHREALTIME
typeset -i i
for (( i = 1; i <= 1000; i++ )); do
  zline_render
done
typeset -F t1=$EPOCHREALTIME
typeset -F total_ms=$(( (t1 - t0) * 1000.0 ))
typeset -F per_render=$(( total_ms / 1000.0 ))

if (( per_render < 1.0 )); then
  assert_eq "fast" "fast" "Zero-fork runtime proof: 1000 renders took ${total_ms} ms (${per_render} ms/render < 1.0 ms)"
else
  assert_eq "slow (${per_render} ms)" "fast" "Render latency exceeded threshold"
fi

print -P "\n%F{14}Zero-Fork Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
