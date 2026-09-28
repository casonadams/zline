#!/usr/bin/env zsh
# Test suite for Slice 25: Vi Mode Indicator & Multi-Cloud Segments

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

print -P "%F{14}Running Slice 25 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice25.XXXXXX")"
cd "$test_dir"

# 1. vi_mode segment
KEYMAP="main"
_zline_vi_mode="main"
zline_segment_vi_mode
assert_eq "$_zline_ret_content" "INS" "vi_mode defaults to INS in main keymap"
assert_eq "$_zline_ret_fg" "10" "vi_mode uses color 10 for insert mode"

KEYMAP="vicmd"
_zline_vi_mode="vicmd"
zline_segment_vi_mode
assert_eq "$_zline_ret_content" "NOR" "vi_mode displays NOR in vicmd keymap"
assert_eq "$_zline_ret_fg" "11" "vi_mode uses color 11 for normal mode"

KEYMAP="visual"
_zline_vi_mode="visual"
zline_segment_vi_mode
assert_eq "$_zline_ret_content" "VIS" "vi_mode displays VIS in visual keymap"
assert_eq "$_zline_ret_fg" "13" "vi_mode uses color 13 for visual mode"

# vi_mode --hide-insert
KEYMAP="main"
_zline_vi_mode="main"
zline_segment_vi_mode --hide-insert
assert_eq "$_zline_ret_content" "" "vi_mode --hide-insert hides in insert mode"

KEYMAP="vicmd"
_zline_vi_mode="vicmd"
zline_segment_vi_mode --hide-insert
assert_eq "$_zline_ret_content" "NOR" "vi_mode --hide-insert shows in normal mode"

# vi_mode custom labels
KEYMAP="vicmd"
_zline_vi_mode="vicmd"
zline_segment_vi_mode --normal "NORMAL"
assert_eq "$_zline_ret_content" "NORMAL" "vi_mode honors custom --normal label"

unset KEYMAP _zline_vi_mode

# 2. gcp segment
CLOUDSDK_CORE_PROJECT="production-app-123"
zline_segment_gcp
assert_eq "$_zline_ret_content" "production-app-123" "gcp detects \$CLOUDSDK_CORE_PROJECT"
assert_eq "$_zline_ret_fg" "12" "gcp uses color 12"
unset CLOUDSDK_CORE_PROJECT

mkdir -p gcloud/configurations
print "test-cfg" > gcloud/active_config
cat << 'EOF' > gcloud/configurations/config_test-cfg
[core]
account = dev@example.com
project = enterprise-cloud-456
EOF
CLOUDSDK_CONFIG="${test_dir}/gcloud"
zline_segment_gcp
assert_eq "$_zline_ret_content" "enterprise-cloud-456" "gcp parses project from active_config"
unset CLOUDSDK_CONFIG

# 3. azure segment
ARM_SUBSCRIPTION_NAME="Azure-Enterprise-Sub"
zline_segment_azure
assert_eq "$_zline_ret_content" "Azure-Enterprise-Sub" "azure detects \$ARM_SUBSCRIPTION_NAME"
assert_eq "$_zline_ret_fg" "14" "azure uses color 14"
unset ARM_SUBSCRIPTION_NAME

mkdir -p azure_cfg
cat << 'EOF' > azure_cfg/azureProfile.json
{
  "subscriptions": [
    {
      "id": "111",
      "name": "Staging",
      "isDefault": false
    },
    {
      "id": "222",
      "name": "Prod-Subscription",
      "isDefault": true
    }
  ]
}
EOF
AZURE_CONFIG_DIR="${test_dir}/azure_cfg"
zline_segment_azure
assert_eq "$_zline_ret_content" "Prod-Subscription" "azure parses default subscription from azureProfile.json"
unset AZURE_CONFIG_DIR

# 4. elixir segment
touch mix.exs
zline_segment_elixir
assert_eq "$_zline_ret_content" "ex" "elixir detects mix.exs"
assert_eq "$_zline_ret_fg" "5" "elixir uses color 5"
rm -f mix.exs

print "elixir 1.16.2-otp-26" > .tool-versions
zline_segment_elixir
assert_eq "$_zline_ret_content" "1.16.2-otp-26" "elixir reads .tool-versions"
rm -f .tool-versions

# 5. Documentation completeness
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
assert_eq "$all_documented" "1" "All 47 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 25 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
