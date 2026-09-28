#!/usr/bin/env zsh
# Master test runner for zline

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"

typeset -i total_suites=0
typeset -i passed_suites=0
typeset -i failed_suites=0

print -P "%F{14}=== Running zline Test Suite ===%f\n"

for test_file in "${SCRIPT_DIR}"/test_*.zsh; do
  [[ -f "$test_file" ]] || continue
  (( total_suites += 1 ))
  print -P "%F{15}%BRunning ${test_file:t}%b%f"
  if zsh "$test_file"; then
    (( passed_suites += 1 ))
  else
    (( failed_suites += 1 ))
  fi
  print ""
done

print -P "%F{14}================================%f"
print -P "%F{15}%BTest Suites: %F{10}${passed_suites} passed%f, %F{9}${failed_suites} failed%f, %F{15}${total_suites} total%b%f"

if (( failed_suites > 0 )); then
  exit 1
fi
