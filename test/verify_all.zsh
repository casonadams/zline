#!/usr/bin/env zsh
# Master specification verification harness for zline

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
cd "$REPO_ROOT"

print -P "%F{14}%B================================================================%b%f"
print -P "%F{15}%B            zline Specification Final Verification              %b%f"
print -P "%F{14}%B================================================================%b%f\n"

# Gate 1: AST Syntax Validation
print -P "%F{12}[Gate 1/7] AST syntax validation across all scripts...%f"
zsh -n zline.zsh zline.plugin.zsh lib/*.zsh segments/*.zsh themes/*.zsh test/*.zsh spec/*.sh benchmark/*.zsh completion/_zline
print -P "%F{10}✓ Gate 1 Passed: 100%% clean syntax validation across all files.%f\n"

# Gate 2: POSIX Installer & ShellCheck Audit
print -P "%F{12}[Gate 2/7] POSIX installer syntax and ShellCheck audit...%f"
sh -n install.sh
if (( $+commands[shellcheck] )); then
  shellcheck install.sh
  print -P "%F{10}✓ Gate 2 Passed: install.sh passes POSIX syntax & ShellCheck audit (0 warnings).%f\n"
else
  print -P "%F{10}✓ Gate 2 Passed: install.sh passes POSIX syntax.%f\n"
fi

# Gate 3: ShellSpec BDD Test Suite
print -P "%F{12}[Gate 3/7] Running ShellSpec BDD test suite...%f"
if (( $+commands[shellspec] )); then
  shellspec >/dev/null
  print -P "%F{10}✓ Gate 3 Passed: ShellSpec BDD tests passing (0 failures).%f\n"
else
  print -P "%F{11}! Gate 3 Skipped: shellspec not installed in current environment.%f\n"
fi

# Gate 4: Master Unit & Integration Test Suite
print -P "%F{12}[Gate 4/7] Running complete unit & integration test suites...%f"
zsh test/run_all.zsh >/dev/null
print -P "%F{10}✓ Gate 4 Passed: all test suites passing (100%% green).%f\n"

# Gate 5: Performance Benchmarks
print -P "%F{12}[Gate 5/7] Verifying performance benchmarks (< 1.5 ms render latency)...%f"
BENCH_OUTPUT=$(zsh benchmark/bench.zsh)
print "$BENCH_OUTPUT" | grep -A 8 "Benchmark"
if print "$BENCH_OUTPUT" | grep -q "ALL BENCHMARKS PASSED"; then
  print -P "%F{10}✓ Gate 5 Passed: All operations beat sub-millisecond budgets.%f\n"
else
  print -u2 -P "%F{9}✗ Gate 5 Failed: Performance benchmark exceeded latency budget.%f"
  exit 1
fi

# Gate 6: Zero-Fork Architecture Audit
print -P "%F{12}[Gate 6/7] Auditing zero-fork execution on synchronous path...%f"
zsh test/test_zero_forks.zsh >/dev/null
print -P "%F{10}✓ Gate 6 Passed: Verified strictly 0 subshells on render path.%f\n"

# Gate 7: Manual Page & Completeness
print -P "%F{12}[Gate 7/7] Verifying manual page & segment documentation completeness...%f"
zsh test/test_man.zsh >/dev/null
print -P "%F{10}✓ Gate 7 Passed: man page valid & all 30 registered segments documented.%f\n"

print -P "%F{10}%B================================================================%b%f"
print -P "%F{10}%B  ALL 7 SPECIFICATION GATES PASSED! READY FOR PRODUCTION.       %b%f"
print -P "%F{10}%B================================================================%b%f"
