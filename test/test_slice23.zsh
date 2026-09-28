#!/usr/bin/env zsh
# Test suite for Slice 27: Extended Systems & Functional Runtimes

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

print -P "%F{14}Running Slice 27 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice27.XXXXXX")"
cd "$test_dir"

# 1. crystal segment
touch shard.yml
zline_segment_crystal
assert_eq "$_zline_ret_content" "cr" "crystal detects shard.yml"
assert_eq "$_zline_ret_fg" "15" "crystal uses color 15"
rm -f shard.yml

print "crystal 1.11.2" > .tool-versions
zline_segment_crystal
assert_eq "$_zline_ret_content" "1.11.2" "crystal reads .tool-versions"
rm -f .tool-versions

# 2. haskell segment
touch stack.yaml
zline_segment_haskell
assert_eq "$_zline_ret_content" "hs" "haskell detects stack.yaml"
assert_eq "$_zline_ret_fg" "5" "haskell uses color 5"
rm -f stack.yaml

print "haskell 9.4.8" > .tool-versions
zline_segment_haskell
assert_eq "$_zline_ret_content" "9.4.8" "haskell reads .tool-versions"
rm -f .tool-versions

# 3. scala segment
touch build.sbt
zline_segment_scala
assert_eq "$_zline_ret_content" "scala" "scala detects build.sbt"
assert_eq "$_zline_ret_fg" "9" "scala uses color 9"
rm -f build.sbt

print "scala 3.3.3" > .tool-versions
zline_segment_scala
assert_eq "$_zline_ret_content" "3.3.3" "scala reads .tool-versions"
rm -f .tool-versions

# 4. kotlin segment
touch build.gradle.kts
zline_segment_kotlin
assert_eq "$_zline_ret_content" "kt" "kotlin detects build.gradle.kts"
assert_eq "$_zline_ret_fg" "13" "kotlin uses color 13"
rm -f build.gradle.kts

print "kotlin 1.9.22" > .tool-versions
zline_segment_kotlin
assert_eq "$_zline_ret_content" "1.9.22" "kotlin reads .tool-versions"
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
assert_eq "$all_documented" "1" "All 45 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 27 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
