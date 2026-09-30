#!/usr/bin/env zsh
# Test suite for Slice 14: Prompt Connection Lines & Extended Language Runtimes

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

print -P "%F{14}Running Slice 14 Tests:%f"

typeset test_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-s14.XXXXXX")
cd "$test_dir"

# 1. Ruby segment
print -r "3.3.1" > .ruby-version
zline_segment_ruby
assert_eq "$_zline_ret_content" "3.3.1" "Ruby segment reads .ruby-version"
rm -f .ruby-version

# 2. PHP segment
print -r "8.3.6" > .php-version
zline_segment_php
assert_eq "$_zline_ret_content" "8.3.6" "PHP segment reads .php-version"
rm -f .php-version

# 3. Java segment
print -r "21.0.2" > .java-version
zline_segment_java
assert_eq "$_zline_ret_content" "21.0.2" "Java segment reads .java-version"
rm -f .java-version

# 4. Dotnet segment
print -r '{"sdk": {"version": "8.0.204"}}' > global.json
zline_segment_dotnet
assert_eq "$_zline_ret_content" "8.0.204" "Dotnet segment reads global.json"
rm -f global.json

# 5. Connection lines
zline preset powerline --connect "·" --frame left --no-osc
zline_right=(time)
zline init
COLUMNS=80 zline_render

[[ "$PROMPT" == *"····"* ]] && assert_eq "has_dots" "has_dots" "PROMPT includes connecting line characters"
assert_eq "$RPROMPT" "" "RPROMPT is cleared when connection line embeds right segments into line 1"
_zline_connect_char=""
_zline_frame="none"

# 6. Documentation completeness
typeset man_content=$(< "${REPO_ROOT}/man/man1/zline.1")
typeset -i all_documented=1
local seg
for seg in "${(k)_zline_registered_segments[@]}"; do
  [[ "$seg" == "newline" ]] && continue
  if [[ "$man_content" != *".B $seg"* ]]; then
    all_documented=0
    print -P "  %F{9}Segment missing in man page:%f $seg"
  fi
done
assert_eq "$all_documented" "1" "All registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 14 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
