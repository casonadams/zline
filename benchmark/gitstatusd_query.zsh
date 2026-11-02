#!/usr/bin/env zsh
# Measures gitstatusd (Powerlevel10k's git backend) query latency for one repo.
# Must run in an interactive shell on a pty: gitstatus's worker requires job control.
# Usage: zsh -fi benchmark/gitstatusd_query.zsh <p10k_dir> <repo> [iterations]

zmodload zsh/datetime

typeset p10k_dir="$1" repo="$2"
typeset -i iters="${3:-50}" i
set --
source "${p10k_dir}/gitstatus/gitstatus.plugin.zsh"
gitstatus_stop BENCH 2>/dev/null
gitstatus_start -t 60 BENCH || { print "GSD_ERROR start failed"; exit 1; }

typeset -F t0=$EPOCHREALTIME
gitstatus_query -d "$repo" BENCH || { print "GSD_ERROR query failed"; exit 1; }
typeset -F cold=$(( (EPOCHREALTIME - t0) * 1000.0 ))

t0=$EPOCHREALTIME
for (( i = 1; i <= iters; i++ )); do
  gitstatus_query -d "$repo" BENCH
done
typeset -F warm=$(( (EPOCHREALTIME - t0) * 1000.0 / iters ))

printf "GSD_RESULT %.3f %.3f %s\n" "$cold" "$warm" "${VCS_STATUS_RESULT:-?}"
gitstatus_stop BENCH
exit
