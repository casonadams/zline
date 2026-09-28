#!/usr/bin/env zsh
# Test suite for Slice 29: Cloud Native Infrastructure Segments (Helm & Pulumi)

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

print -P "%F{14}Running Slice 29 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice29.XXXXXX")"
cd "$test_dir"

# 1. helm segment
cat << 'EOF' > Chart.yaml
apiVersion: v2
name: api-gateway
description: A Helm chart for Kubernetes
version: 1.2.3
EOF

zline_segment_helm
assert_eq "$_zline_ret_content" "api-gateway:1.2.3" "helm detects Chart.yaml with name and version"
assert_eq "$_zline_ret_fg" "14" "helm uses color 14"
rm -f Chart.yaml

touch helmfile.yaml
zline_segment_helm
assert_eq "$_zline_ret_content" "helmfile" "helm detects helmfile.yaml"
rm -f helmfile.yaml

# 2. pulumi segment
cat << 'EOF' > Pulumi.yaml
name: core-infrastructure
runtime: nodejs
description: Pulumi cloud infrastructure
EOF

zline_segment_pulumi
assert_eq "$_zline_ret_content" "core-infrastructure" "pulumi detects Pulumi.yaml with project name"
assert_eq "$_zline_ret_fg" "13" "pulumi uses color 13"

PULUMI_STACK="production"
zline_segment_pulumi
assert_eq "$_zline_ret_content" "core-infrastructure:production" "pulumi formats project and stack name"
unset PULUMI_STACK
rm -f Pulumi.yaml

# 3. Documentation completeness
typeset man_content
man_content="$(< "${REPO_ROOT}/man/man1/zline.1")"
typeset -i all_documented=1
local seg
for seg in "${(k)_zline_registered_segments[@]}"; do
  [[ "$seg" == "newline" ]] && continue
  if [[ "$man_content" != *".B $seg"* ]]; then
    all_documented=0
    print -P "  %F{9}Segment missing in man page:%f $seg"
  fi
done
assert_eq "$all_documented" "1" "All 49 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 29 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
