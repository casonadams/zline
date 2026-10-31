#!/usr/bin/env zsh
# Test suite: git cache stays visible while revalidating; worker coalesces and recovers

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

source "${REPO_ROOT}/zline.zsh"
_zline_osc=0

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

print -P "%F{14}Running Worker Resilience Tests:%f"

# 1. Cached git details survive a preexec/chpwd refresh request
typeset tmp_repo
tmp_repo="$(mktemp -d "${TMPDIR:-/tmp}/zline-wr.XXXXXX")"
mkdir -p "${tmp_repo}/.git"
print -r -- "ref: refs/heads/topic" > "${tmp_repo}/.git/HEAD"
cd "$tmp_repo"

_zline_git_cache_valid=1
_zline_git_cache_dir="$tmp_repo"
_zline_git_cache_branch="topic"
_zline_git_cache_staged=3
_zline_git_cache_unstaged=0
_zline_git_cache_untracked=0
_zline_git_cache_ahead=0
_zline_git_cache_behind=0
_zline_git_cache_conflicts=0

zline_segment_git
typeset before="$_zline_ret_content"
_zline_git_on_change
zline_segment_git
assert_eq "$_zline_ret_content" "$before" "details stay visible after preexec marks the cache stale"
assert_eq "$_zline_git_cache_stale" "1" "cache is flagged stale so a refresh is requested"

mkdir -p "${tmp_repo}/other/.git"
print -r -- "ref: refs/heads/elsewhere" > "${tmp_repo}/other/.git/HEAD"
cd "${tmp_repo}/other"
zline_segment_git
assert_eq "$_zline_git_cache_valid" "0" "details are dropped when the repository root changes"

# 2. Acking the newest request clears stale; older acks do not
_zline_worker_seq=7
_zline_worker_last_acked=0
_zline_git_cache_stale=1
_zline_worker_apply_reply "5:git:topic:1:0:0:0:0:0:${tmp_repo}"
assert_eq "$_zline_git_cache_stale" "1" "reply for a superseded request leaves cache stale"
assert_eq "$(( _zline_worker_seq > _zline_worker_last_acked ))" "1" "request still pending after superseded reply"
_zline_worker_apply_reply "7:git:topic:1:0:0:0:0:0:${tmp_repo}"
assert_eq "$_zline_git_cache_stale" "0" "reply for the newest request clears stale"
assert_eq "$(( _zline_worker_seq > _zline_worker_last_acked ))" "0" "nothing pending after newest reply"

# 3. Directories containing colons survive the reply round-trip
_zline_worker_apply_reply "8:git:topic:0:0:0:0:0:0:/tmp/a:b:c"
assert_eq "$_zline_git_cache_dir" "/tmp/a:b:c" "colon in repository path is preserved"

# 4. Worker coalesces queued requests and replies only for the newest
cd "$REPO_ROOT"
_zline_git_provider_slow() {
  sleep 0.4
  print -r -- "${1}:git:b:0:0:0:0:0:0:${2}"
}
_zline_git_provider="slow"
_zline_worker_seq=0
_zline_worker_last_acked=0
_zline_worker_pending_dir=""
_zline_worker_start --force
_zline_worker_send git /dirA
sleep 0.1
_zline_worker_send git /dirB
_zline_worker_send git /dirC
typeset r1="" r2="" r3=""
read -t 3 -u "$_zline_worker_res_fd" -r r1 || true
read -t 3 -u "$_zline_worker_res_fd" -r r2 || true
read -t 1 -u "$_zline_worker_res_fd" -r r3 || true
assert_eq "${r1%%:*}" "1" "first request is answered"
assert_eq "${r2%%:*}" "3" "queued middle request is dropped; newest is answered"
assert_eq "$r3" "" "no extra replies for coalesced requests"

# 5. A stuck request restarts the worker instead of blocking updates forever
typeset -i old_pid=$_zline_worker_pid
_zline_worker_seq=10
_zline_worker_last_acked=5
_zline_worker_sent_at=$(( EPOCHSECONDS - 60 ))
_zline_worker_pending_dir="/stuck"
_zline_worker_send git /fresh
assert_eq "$(( _zline_worker_pid > 0 && _zline_worker_pid != old_pid ))" "1" "worker restarted after request exceeded the timeout"
assert_eq "$_zline_worker_pending_dir" "/fresh" "fresh request sent after restart"
_zline_worker_stop

cd /
rm -rf "$tmp_repo"

print -P "\n%F{14}Worker Resilience Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
