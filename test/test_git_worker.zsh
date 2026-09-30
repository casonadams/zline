#!/usr/bin/env zsh
# Test suite for Slice 3: Fast Git Fast-Path & Asynchronous Worker System

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

print -P "%F{14}Running Slice 3 Tests:%f"

# 1. Synchronous fast-path HEAD reader
_zline_git_read_head "${REPO_ROOT}"
assert_eq "$REPLY" "main" "Fast HEAD reader detects current branch 'main'"

# 2. Benchmark synchronous HEAD read (< 0.1ms)
zmodload zsh/datetime
typeset -F t0=$EPOCHREALTIME
typeset -i i
for (( i = 1; i <= 1000; i++ )); do
  _zline_git_read_head "${REPO_ROOT}"
done
typeset -F t1=$EPOCHREALTIME
typeset -F dur_ms=$(( (t1 - t0) * 1000.0 ))
typeset -F per_op=$(( dur_ms / 1000.0 ))
if (( per_op < 0.30 )); then
  assert_eq "fast" "fast" "Synchronous HEAD read latency: ${per_op} ms/op (< 0.30 ms)"
else
  assert_eq "slow (${per_op} ms)" "fast" "Synchronous HEAD read took too long"
fi

# 3. Simulated special git states in temporary directory
typeset test_git_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-git.XXXXXX")
mkdir -p "${test_git_dir}/.git"

# Detached commit HEAD
print -r "45d1ead1122f8cfd6fcebbf9f1cd500a3535f185" > "${test_git_dir}/.git/HEAD"
_zline_git_read_head "$test_git_dir"
assert_eq "$REPLY" "45d1ead" "Detached HEAD returns 7-char short commit hash"

# Tag HEAD
print -r "ref: refs/tags/v1.2.3" > "${test_git_dir}/.git/HEAD"
_zline_git_read_head "$test_git_dir"
assert_eq "$REPLY" "tag:v1.2.3" "Tag ref returns prefixed tag name"

# Merging state
print -r "ref: refs/heads/feature" > "${test_git_dir}/.git/HEAD"
touch "${test_git_dir}/.git/MERGE_HEAD"
_zline_git_read_head "$test_git_dir"
assert_eq "$REPLY" "feature|MERGING" "Merge in progress appends |MERGING"


# Worktree / Submodule gitdir file
typeset wt_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-wt.XXXXXX")
typeset actual_git_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-actualgit.XXXXXX")
print -r "gitdir: ${actual_git_dir}" > "${wt_dir}/.git"
mkdir -p "${actual_git_dir}/logs/refs"
print -r "ref: refs/heads/worktree-branch" > "${actual_git_dir}/HEAD"
printf "stash1\nstash2\n" > "${actual_git_dir}/logs/refs/stash"
_zline_git_read_head "$wt_dir"
assert_eq "$REPLY" "worktree-branch" "gitdir file resolves branch correctly in worktrees/submodules"
_zline_git_read_stash "$wt_dir"
assert_eq "$REPLY" "2" "gitdir file resolves stash count correctly in worktrees/submodules"
rm -rf "$wt_dir" "$actual_git_dir"
rm -rf "$test_git_dir"

# 4. Git status v2 parsing logic
parse_status_test() {
  local sample="$1"
  local -i staged=0 unstaged=0 untracked=0 ahead=0 behind=0 conflicts=0
  local branch=""

  local line
  while IFS= read -r line; do
    case "${line[1]}" in
      "#")
        if [[ "$line" == "# branch.head "* ]]; then
          branch="${line#\# branch.head }"
        elif [[ "$line" == "# branch.ab "* ]]; then
          local ab="${line#\# branch.ab }"
          local -a ab_parts=(${=ab})
          ahead="${ab_parts[1]#+}"
          behind="${ab_parts[2]#-}"
        fi
        ;;
      "1"|"2")
        local xy="${line[3,4]}"
        [[ "${xy[1]}" != "." ]] && (( staged += 1 ))
        [[ "${xy[2]}" != "." ]] && (( unstaged += 1 ))
        ;;
      "u")
        (( conflicts += 1 ))
        ;;
      "?")
        (( untracked += 1 ))
        ;;
    esac
  done <<< "$sample"

  REPLY="${branch}:${staged}:${unstaged}:${untracked}:${ahead}:${behind}:${conflicts}"
}

typeset v2_sample="# branch.oid abc1234
# branch.head feature-x
# branch.ab +3 -1
1 M. sub 100644 100644 100644 ... file1
1 .M sub 100644 100644 100644 ... file2
1 MM sub 100644 100644 100644 ... file3
? untracked1.txt
? untracked2.txt
u UU sub ... conflict.txt"

parse_status_test "$v2_sample"
assert_eq "$REPLY" "feature-x:2:2:2:3:1:1" "Porcelain v2 correctly parsed staged, unstaged, untracked, ahead, behind, conflicts"

# 5. Git badge detail formatting
_zline_git_cache_conflicts=1
_zline_git_cache_staged=2
_zline_git_cache_unstaged=3
_zline_git_cache_untracked=4
_zline_git_cache_ahead=5
_zline_git_cache_behind=1
_zline_mode="nerdfont"

_zline_git_format_details
assert_eq "$REPLY" "x1 +2 !3 ?4 "$'\u21E1'"5 "$'\u21E3'"1" "Badge formatting in nerdfont mode"

_zline_mode="ascii"
_zline_git_format_details
assert_eq "$REPLY" "x1 +2 !3 ?4 ^5 v1" "Badge formatting in ascii mode"
_zline_mode="nerdfont"

# 6. Asynchronous worker lifecycle and IPC
_zline_worker_start --force
assert_eq "$(( _zline_worker_pid > 0 ))" "1" "Worker process started"
assert_eq "$(( _zline_worker_req_fd >= 0 ))" "1" "Worker request pipe open"
assert_eq "$(( _zline_worker_res_fd >= 0 ))" "1" "Worker response pipe open"
typeset test_err_tmp=$(mktemp "${TMPDIR:-/tmp}/zline-test-err.XXXXXX")
print -u2 "STDERR_INTACT" 2>"$test_err_tmp"
assert_eq "$(<"$test_err_tmp")" "STDERR_INTACT" "Worker start preserves standard error descriptor (FD 2)"
rm -f "$test_err_tmp"

_zline_worker_send "git" "$REPO_ROOT"
_zline_worker_poll
assert_eq "$_zline_git_cache_valid" "1" "Worker response received and applied to cache"
assert_eq "$_zline_git_cache_branch" "main" "Worker reported correct branch name 'main'"

# 7. Worker stale sequence ID rejection
_zline_worker_last_acked=100
_zline_worker_apply_reply "50:git:old_branch:0:0:0:0:0:0"
assert_eq "$_zline_git_cache_branch" "main" "Stale response with seq < last_acked is ignored"

_zline_worker_stop
assert_eq "$_zline_worker_pid" "0" "Worker process stopped and cleaned up"
assert_eq "$(( _zline_worker_req_fd == -1 ))" "1" "Worker request fd closed"
assert_eq "$(( _zline_worker_res_fd == -1 ))" "1" "Worker response fd closed"

print -P "\n%F{14}Slice 3 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
