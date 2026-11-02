#!/usr/bin/env zsh
# Measures Powerlevel10k per-prompt cost (precmd hooks + prompt expansion).
# Must run in an interactive shell on a pty: p10k's worker requires job control.
# Usage: zsh -fi benchmark/p10k_render.zsh <p10k_dir> <workdir> [iterations]

zmodload zsh/datetime

typeset p10k_dir="$1" workdir="$2"
typeset -i iters="${3:-300}" i
typeset f

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
typeset -g GITSTATUS_LOG_LEVEL=
source "${p10k_dir}/powerlevel10k.zsh-theme"
source "${p10k_dir}/config/p10k-lean.zsh"
setopt prompt_subst
cd "$workdir"

for (( i = 1; i <= 5; i++ )); do
  for f in $precmd_functions; do $f; done
  sleep 0.3
done

typeset -F t0=$EPOCHREALTIME
for (( i = 1; i <= iters; i++ )); do
  for f in $precmd_functions; do $f; done
  : ${(e)${(%)PROMPT}}
done
typeset -F t1=$EPOCHREALTIME

printf "P10K_RESULT %d %.4f\n" "$iters" "$(( (t1 - t0) * 1000.0 / iters ))"
exit
