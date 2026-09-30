#!/usr/bin/env zsh
# Benchmark suite for zline prompt engine

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

typeset -gi failed_benchmarks=0

print -P "%F{14}%B============================================================%b%f"
print -P "%F{15}%B              zline Performance Benchmarks                  %b%f"
print -P "%F{14}%B============================================================%b%f\n"

printf "%-32s %10s %12s %10s %8s\n" "Benchmark" "Iterations" "Per Op" "Target" "Status"
printf "%-32s %10s %12s %10s %8s\n" "--------------------------------" "----------" "------------" "----------" "--------"

bench_op() {
  local name="$1"
  local -i iters="$2"
  local target_str="$3"
  local -F target_ms="$4"
  local code="$5"

  local -F t0=$EPOCHREALTIME
  local -i i
  for (( i = 1; i <= iters; i++ )); do
    eval "$code"
  done
  local -F t1=$EPOCHREALTIME
  local -F total_ms=$(( (t1 - t0) * 1000.0 ))
  local -F per_op_ms=$(( total_ms / iters ))

  local bench_status="PASS"
  local status_col="%F{10}"
  if (( per_op_ms > target_ms )); then
    bench_status="FAIL"
    status_col="%F{9}"
    (( failed_benchmarks += 1 ))
  fi

  local per_op_fmt
  if (( per_op_ms < 0.001 )); then
    per_op_fmt=$(printf "%.4f ms" "$per_op_ms")
  elif (( per_op_ms < 0.1 )); then
    per_op_fmt=$(printf "%.3f ms" "$per_op_ms")
  else
    per_op_fmt=$(printf "%.2f ms" "$per_op_ms")
  fi

  printf "%-32s %10d %12s %10s " "$name" "$iters" "$per_op_fmt" "$target_str"
  print -P "${status_col}${bench_status}%f"
}

# 1. Warm synchronous prompt render (powerline preset)
zline preset powerline --no-osc
zline init
bench_op "Sync Prompt Render (Powerline)" 1000 "< 2.50 ms" 2.50 "zline_render"

# 2. Warm synchronous prompt render (lean preset)
zline preset lean --no-osc
zline init
bench_op "Sync Prompt Render (Lean)" 1000 "< 2.00 ms" 2.00 "zline_render"

# 3. Path Shortening & Git Anchor
typeset -a bench_aliases=("--alias" "github.com=gith")
bench_op "Directory Shortening & Anchor" 1000 "< 0.40 ms" 0.40 "_zline_dir_format_path '$PWD' 1 1 'git' bench_aliases"

# 4. Synchronous Git HEAD Reader
bench_op "Synchronous Git HEAD Reader" 1000 "< 0.40 ms" 0.40 "_zline_git_read_head '$PWD'"
# 5. Instant Prompt Snapshot Load
typeset bench_tmp=$(mktemp -d "${TMPDIR:-/tmp}/zline-bench.XXXXXX")
_zline_instant_cache_dir="$bench_tmp"
_zline_instant_file="${bench_tmp}/instant-bench.zsh"
_zline_instant_last_prompt=""
_zline_instant_last_rprompt=""
_zline_instant_save
bench_op "Instant Prompt Load" 500 "< 0.50 ms" 0.50 "source '$_zline_instant_file' >/dev/null"
rm -rf "$bench_tmp"

print -P "\n%F{14}%B============================================================%b%f"

if (( failed_benchmarks > 0 )); then
  print -P "%F{9}%BFAILED: ${failed_benchmarks} benchmark(s) exceeded target thresholds.%b%f"
  exit 1
else
  print -P "%F{10}%BALL BENCHMARKS PASSED!%b%f"
fi
