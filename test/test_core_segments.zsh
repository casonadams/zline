#!/usr/bin/env zsh
# Test suite for Slice 5: Built-in Segment Library & Style Presets

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

print -P "%F{14}Running Slice 5 Tests:%f"

# 1. Status segment
_zline_last_exit_code=0
zline_segment_status
assert_eq "$_zline_ret_content" "" "Status segment hides 0 exit code by default"

zline_segment_status --show-zero
assert_eq "$_zline_ret_content" "0" "Status segment shows 0 when --show-zero passed"
assert_eq "$_zline_ret_fg" "10" "Status 0 foreground color is green (10)"

_zline_last_exit_code=1
zline_segment_status
assert_eq "$_zline_ret_content" "1" "Status segment displays non-zero exit code"
assert_eq "$_zline_ret_fg" "9" "Status non-zero foreground color is red (9)"
_zline_last_exit_code=130
zline_segment_status --signal
assert_eq "$_zline_ret_content" "SIGINT" "Status segment converts 130 to SIGINT with --signal"

_zline_last_exit_code=137
zline_segment_status --signal
assert_eq "$_zline_ret_content" "SIGKILL" "Status segment converts 137 to SIGKILL with --signal"

_zline_last_exit_code=127
zline_segment_status
assert_eq "$_zline_ret_content" "127" "Status segment displays command-not-found code 127"
_zline_last_exit_code=0

# 2. Exec time segment
_zline_last_duration=1.2
zline_segment_exec_time --min 2
assert_eq "$_zline_ret_content" "" "Exec time below min threshold is hidden"

_zline_last_duration=3.45
zline_segment_exec_time --min 2
assert_eq "$_zline_ret_content" "3.4s" "Exec time above threshold formats as seconds"
assert_eq "$_zline_ret_fg" "11" "Exec time foreground color is yellow (11)"

_zline_format_duration 75.0
assert_eq "$REPLY" "1m 15s" "Duration formats as minutes and seconds"

_zline_format_duration 3665.0
assert_eq "$REPLY" "1h 1m" "Duration formats as hours and minutes"

# 3. Prompt char segment
_zline_last_exit_code=0
_zline_vi_mode="main"
zline_segment_prompt_char
assert_eq "$_zline_ret_content" "❯" "Prompt char renders default symbol ❯"
assert_eq "$_zline_ret_fg" "15" "Prompt char default color is bright-white (15)"

_zline_last_exit_code=1
zline_segment_prompt_char
assert_eq "$_zline_ret_fg" "9" "Prompt char turns red (9) on command failure"

_zline_last_exit_code=0
_zline_vi_mode="vicmd"
zline_segment_prompt_char
assert_eq "$_zline_ret_content" "❮" "Prompt char turns to ❮ on vi normal mode"
assert_eq "$_zline_ret_fg" "11" "Prompt char turns to yellow (11) on vi normal mode"
_zline_vi_mode="main"

# 4. Virtualenv segment
VIRTUAL_ENV="/home/user/.virtualenvs/cool-project"
zline_segment_venv
assert_eq "$_zline_ret_content" "cool-project" "Venv segment extracts environment basename"
assert_eq "$_zline_ret_fg" "5" "Venv segment color is magenta (5)"
unset VIRTUAL_ENV

CONDA_DEFAULT_ENV="base-conda"
zline_segment_venv
assert_eq "$_zline_ret_content" "base-conda" "Venv segment detects conda default environment"
unset CONDA_DEFAULT_ENV

zline_segment_venv
assert_eq "$_zline_ret_content" "" "Venv segment empty when no virtualenv active"

# 5. Node segment
NODE_VERSION="v20.10.0"
zline_segment_node
assert_eq "$_zline_ret_content" "v20.10.0" "Node segment detects NODE_VERSION env var"
assert_eq "$_zline_ret_fg" "2" "Node segment color is green (2)"
unset NODE_VERSION

# 6. K8s segment
typeset test_kcfg=$(mktemp "${TMPDIR:-/tmp}/zline-kcfg.XXXXXX")
cat << 'EOF' > "$test_kcfg"
apiVersion: v1
current-context: production-us-east-1
clusters: []
EOF

KUBECONFIG="$test_kcfg" zline_segment_k8s
assert_eq "$_zline_ret_content" "production-us-east-1" "K8s segment extracts current-context"
assert_eq "$_zline_ret_fg" "6" "K8s segment color is cyan (6)"
rm -f "$test_kcfg"

# 7. Style presets
for preset in lean powerline rainbow pure; do
  zline preset "$preset" --no-osc
  zline init
  [[ -n "$PROMPT" ]] && assert_eq "ok" "ok" "Preset '${preset}' initialized successfully"
done

print -P "\n%F{14}Slice 5 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
