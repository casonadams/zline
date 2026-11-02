#!/usr/bin/env zsh
# Git status latency on a large repository: zline worker task vs gitstatusd.
# Usage: zsh benchmark/git_latency.zsh [repo_dir]
#   repo_dir omitted -> a synthetic repo (ZLINE_BENCH_FILES files, default 30000)
#   P10K_DIR         -> Powerlevel10k checkout used for the gitstatusd column

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"
source "${REPO_ROOT}/lib/worker.zsh"
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null

typeset repo="$1" tmp=""
typeset -i nfiles="${ZLINE_BENCH_FILES:-30000}" i

if [[ -z "$repo" ]]; then
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/zline-gitbench.XXXXXX") || exit 1
  trap 'rm -rf "$tmp"' EXIT
  repo="$tmp/repo"
  mkdir -p "$repo" && cd "$repo" || exit 1
  git init -q . && git config user.email bench@example.com && git config user.name bench
  for (( i = 0; i < nfiles; i++ )); do
    mkdir -p "d$(( i % 300 ))"
    : > "d$(( i % 300 ))/f$i.txt"
  done
  git add -A && git commit -q -m init
  for (( i = 0; i < 10; i++ )); do print changed >> "d0/f$(( i * 300 )).txt"; done
  for (( i = 0; i < 10; i++ )); do : > "untracked$i"; done
fi

typeset -i tracked=$(git -C "$repo" ls-files | wc -l)

typeset -F t0 cold warm
typeset -i iters=20
t0=$EPOCHREALTIME
_zline_worker_git_task 1 "$repo" > /dev/null
cold=$(( (EPOCHREALTIME - t0) * 1000.0 ))
t0=$EPOCHREALTIME
for (( i = 1; i <= iters; i++ )); do
  _zline_worker_git_task 1 "$repo" > /dev/null
done
warm=$(( (EPOCHREALTIME - t0) * 1000.0 / iters ))

print "Git status latency: ${tracked} tracked files (${repo})"
printf "%-34s %12s %12s\n" "Backend" "First query" "Steady state"
printf "%-34s %9.1f ms %9.1f ms\n" "zline worker (git status CLI)" "$cold" "$warm"

typeset p10k_dir=""
for p10k_dir in "${P10K_DIR:-}" "$HOME/powerlevel10k" "$HOME/.powerlevel10k"; do
  [[ -n "$p10k_dir" && -f "$p10k_dir/gitstatus/gitstatus.plugin.zsh" ]] && break
  p10k_dir=""
done
if [[ -n "$p10k_dir" ]] && (( $+commands[script] )); then
  typeset cmd="zsh -fi ${(q)SCRIPT_DIR}/gitstatusd_query.zsh ${(q)p10k_dir} ${(q)repo} 50" out
  if [[ "$OSTYPE" == darwin* || "$OSTYPE" == *bsd* ]]; then
    out=$(script -q /dev/null zsh -c "$cmd" 2>&1 </dev/null)
  else
    out=$(script -qec "$cmd" /dev/null 2>&1 </dev/null)
  fi
  if [[ "$out" =~ 'GSD_RESULT ([0-9.]+) ([0-9.]+)' ]]; then
    printf "%-34s %9.1f ms %9.1f ms\n" "gitstatusd (p10k)" "${match[1]}" "${match[2]}"
  else
    print "gitstatusd benchmark produced no result: ${out[1,200]}"
  fi
fi
