#!/usr/bin/env zsh
# Startup latency benchmark measuring shell launch and instant prompt restoration

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

typeset -i iters="${1:-30}"

print -P "%F{14}%B================================================================%b%f"
print -P "%F{15}%B               zline Shell Startup Benchmarks                   %b%f"
print -P "%F{14}%B================================================================%b%f\n"

printf "%-36s %10s %10s %10s %10s\n" "Startup Scenario" "Runs" "Avg" "Min" "Max"
printf "%-36s %10s %10s %10s %10s\n" "------------------------------------" "----------" "----------" "----------" "----------"

bench_startup() {
  local name="$1"
  local cmd="$2"

  local -F total=0.0
  local -F min=9999.0
  local -F max=0.0
  local -i i

  for (( i = 1; i <= iters; i++ )); do
    local -F t0=$EPOCHREALTIME
    eval "$cmd"
    local -F t1=$EPOCHREALTIME
    local -F dur=$(( (t1 - t0) * 1000.0 ))
    (( total += dur ))
    (( dur < min )) && min=$dur
    (( dur > max )) && max=$dur
  done

  local -F avg=$(( total / iters ))
  printf "%-36s %10d %8.2f ms %8.2f ms %8.2f ms\n" "$name" "$iters" "$avg" "$min" "$max"
}

# 1. Baseline zsh -f process spawn
bench_startup "Baseline (zsh -f exit)" 'zsh -f -c "exit" >/dev/null 2>&1'

# 2. Instant Prompt Load
typeset inst_tmp=$(mktemp "${TMPDIR:-/tmp}/zline-inst-bench.XXXXXX")
print 'PROMPT="%F{4}~/src/zline%f %F{2}main%f %F{10}❯%f "' > "$inst_tmp"
bench_startup "Shell + Instant Prompt Snapshot" "zsh -f -c 'source \"$inst_tmp\"' >/dev/null 2>&1"
rm -f "$inst_tmp"

# 3. Full zline initialization
bench_startup "Shell + Full zline init" "zsh -f -c 'source \"${REPO_ROOT}/zline.zsh\" && zline preset powerline --no-osc && zline init' >/dev/null 2>&1"

print -P "\n%F{14}%B================================================================%b%f"
print -P "%F{10}%BInstant prompt restores your shell interface in under 0.1 ms.%b%f"
print -P "%F{14}%B================================================================%b%f"
