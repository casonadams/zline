#!/usr/bin/env zsh
# Test suite: docker and k8s context segments cache by file stamp but never serve stale values

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

print -P "%F{14}Running Context Cache Tests:%f"

typeset tmp_home
tmp_home="$(mktemp -d "${TMPDIR:-/tmp}/zline-cc.XXXXXX")"
mkdir -p "${tmp_home}/.docker" "${tmp_home}/.kube"
typeset saved_home="$HOME"
HOME="$tmp_home"
unset DOCKER_CONTEXT DOCKER_HOST
typeset -x KUBECONFIG="${tmp_home}/.kube/config"

# 1. A file edited moments ago gets no stamp (never cached); an old file does
print -r -- "aaa" > "${tmp_home}/stamp"
_zline_file_stamp "${tmp_home}/stamp"
assert_eq "$REPLY" "" "recently modified files are not cacheable"
touch -t 202401010000 "${tmp_home}/stamp"
_zline_file_stamp "${tmp_home}/stamp"
typeset stamp_a="$REPLY"
print -r -- "aaaa" > "${tmp_home}/stamp"
touch -t 202401010000 "${tmp_home}/stamp"
_zline_file_stamp "${tmp_home}/stamp"
typeset -i changed=0
[[ -n "$stamp_a" && "$stamp_a" != "$REPLY" ]] && changed=1
assert_eq "$changed" "1" "stamp changes when only the size changes"

# 2. Docker context follows edits made back to back, including same-size edits
print -r -- '{"currentContext": "prod"}' > "${tmp_home}/.docker/config.json"
zline_segment_docker
assert_eq "$_zline_ret_content" "prod" "docker context is read from config.json"
print -r -- '{"currentContext": "staging"}' > "${tmp_home}/.docker/config.json"
zline_segment_docker
assert_eq "$_zline_ret_content" "staging" "docker context updates immediately after an edit"
print -r -- '{"currentContext": "default"}' > "${tmp_home}/.docker/config.json"
zline_segment_docker
assert_eq "$_zline_ret_content" "" "docker default context is hidden after a same-size edit"

# 3. An unchanged old file is served from the cache
print -r -- '{"currentContext": "cached"}' > "${tmp_home}/.docker/config.json"
touch -t 202401010000 "${tmp_home}/.docker/config.json"
zline_segment_docker
print -r -- '{"currentContext": "hidden"}' > "${tmp_home}/.docker/config.json"
touch -t 202401010000 "${tmp_home}/.docker/config.json"
zline_segment_docker
assert_eq "$_zline_ret_content" "cached" "unchanged mtime and size reuse the cached docker context"

# 4. Kubernetes context follows edits made back to back
print -r -- "current-context: dev" > "${KUBECONFIG}"
zline_segment_k8s
assert_eq "$_zline_ret_content" "dev" "k8s context is read from kubeconfig"
print -r -- "current-context: prod" > "${KUBECONFIG}"
zline_segment_k8s
assert_eq "$_zline_ret_content" "prod" "k8s context updates immediately after a same-size edit"

HOME="$saved_home"
rm -rf "$tmp_home"

print -P "\n%F{14}Context Cache Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
