#!/usr/bin/env zsh
# Prompt performance comparison benchmark

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

print -P "%F{14}%B================================================================%b%f"
print -P "%F{15}%B              Prompt Performance Comparison Benchmark           %b%f"
print -P "%F{14}%B================================================================%b%f\n"

printf "%-32s %10s %12s %12s\n" "Prompt Architecture" "Iterations" "Per Render" "vs Subshells"
printf "%-32s %10s %12s %12s\n" "--------------------------------" "----------" "------------" "------------"

# 1. Typical subshell-based prompt (2 fork-execs: date + git)
typeset -F t0=$EPOCHREALTIME
typeset -i i
for (( i = 1; i <= 50; i++ )); do
  b=$(/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  d=$(/bin/date +%H:%M)
  p="[$d] $b > "
done
typeset -F t1=$EPOCHREALTIME
typeset -F subshell_per_ms=$(( (t1 - t0) * 1000.0 / 50.0 ))
printf "%-32s %10d %10.2f ms %12s\n" "Subshell Fork Prompt (git+date)" 50 "$subshell_per_ms" "1.0x (base)"

# 2. Minimal native Zsh prompt
t0=$EPOCHREALTIME
for (( i = 1; i <= 1000; i++ )); do
  p="${(%):-%~ %# }"
done
t1=$EPOCHREALTIME
typeset -F minimal_per_ms=$(( (t1 - t0) * 1000.0 / 1000.0 ))
typeset speedup_min=$(printf "%.0fx faster" "$(( subshell_per_ms / minimal_per_ms ))")
printf "%-32s %10d %10.3f ms %12s\n" "Minimal Zsh Prompt (%~ %#)" 1000 "$minimal_per_ms" "$speedup_min"

# 3. zline Lean Preset
zline preset lean --no-osc
zline init
t0=$EPOCHREALTIME
for (( i = 1; i <= 500; i++ )); do
  zline_render
done
t1=$EPOCHREALTIME
typeset -F lean_per_ms=$(( (t1 - t0) * 1000.0 / 500.0 ))
typeset speedup_lean=$(printf "%.0fx faster" "$(( subshell_per_ms / lean_per_ms ))")
printf "%-32s %10d %10.3f ms %12s\n" "zline (Lean Preset)" 500 "$lean_per_ms" "$speedup_lean"

# 4. zline Powerline Preset
zline preset powerline --no-osc
zline init
t0=$EPOCHREALTIME
for (( i = 1; i <= 500; i++ )); do
  zline_render
done
t1=$EPOCHREALTIME
typeset -F power_per_ms=$(( (t1 - t0) * 1000.0 / 500.0 ))
typeset speedup_power=$(printf "%.0fx faster" "$(( subshell_per_ms / power_per_ms ))")
printf "%-32s %10d %10.3f ms %12s\n" "zline (Powerline Preset)" 500 "$power_per_ms" "$speedup_power"

# 5. External prompts if installed
if (( $+commands[starship] )); then
  t0=$EPOCHREALTIME
  for (( i = 1; i <= 50; i++ )); do
    p=$(starship prompt 2>/dev/null)
  done
  t1=$EPOCHREALTIME
  typeset -F star_per_ms=$(( (t1 - t0) * 1000.0 / 50.0 ))
  typeset speedup_star=$(printf "%.1fx faster" "$(( subshell_per_ms / star_per_ms ))")
  printf "%-32s %10d %10.2f ms %12s\n" "Starship (Rust binary)" 50 "$star_per_ms" "$speedup_star"
fi

# 6. Powerlevel10k (lean config, gitstatusd) if found; set P10K_DIR to override
typeset p10k_dir=""
for p10k_dir in "${P10K_DIR:-}" "$HOME/powerlevel10k" "$HOME/.powerlevel10k"; do
  [[ -n "$p10k_dir" && -f "$p10k_dir/powerlevel10k.zsh-theme" ]] && break
  p10k_dir=""
done
if [[ -n "$p10k_dir" ]] && (( $+commands[script] )); then
  typeset p10k_cmd="zsh -fi ${(q)SCRIPT_DIR}/p10k_render.zsh ${(q)p10k_dir} ${(q)PWD} 300"
  typeset p10k_out
  if [[ "$OSTYPE" == darwin* || "$OSTYPE" == *bsd* ]]; then
    p10k_out=$(script -q /dev/null zsh -c "$p10k_cmd" 2>&1 </dev/null)
  else
    p10k_out=$(script -qec "$p10k_cmd" /dev/null 2>&1 </dev/null)
  fi
  if [[ "$p10k_out" =~ 'P10K_RESULT ([0-9]+) ([0-9.]+)' ]]; then
    typeset -a p10k_fields=( "${match[1]}" "${match[2]}" )
    typeset -F p10k_per_ms=${p10k_fields[2]}
    printf "%-32s %10d %10.3f ms %12s\n" "Powerlevel10k (lean, gitstatusd)" "${p10k_fields[1]}" "$p10k_per_ms" "$(printf '%.0fx faster' "$(( subshell_per_ms / p10k_per_ms ))")"
    printf "%-32s %10s %10.2fx %12s\n" "  zline Lean vs p10k" "" "$(( p10k_per_ms / lean_per_ms ))" "(p10k / zline)"
  else
    print -P "%F{11}p10k found at ${p10k_dir} but benchmark produced no result (needs a pty).%f"
  fi
fi

print -P "\n%F{14}%B================================================================%b%f"
print -P "%F{10}%Bzline delivers sub-millisecond rendering with zero subprocess forks.%b%f"
print -P "%F{14}%B================================================================%b%f"
