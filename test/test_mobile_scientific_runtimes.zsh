#!/usr/bin/env zsh
# Test suite for Slice 28: Mobile, Scientific & Native Ecosystem Runtimes

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

print -P "%F{14}Running Slice 28 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice28.XXXXXX")"
cd "$test_dir"

# 1. swift segment
touch Package.swift
zline_segment_swift
assert_eq "$_zline_ret_content" "swift" "swift detects Package.swift"
assert_eq "$_zline_ret_fg" "9" "swift uses color 9"
rm -f Package.swift

print "5.10.0" > .swift-version
zline_segment_swift
assert_eq "$_zline_ret_content" "5.10.0" "swift reads .swift-version"
rm -f .swift-version

print "swift 5.9.2" > .tool-versions
zline_segment_swift
assert_eq "$_zline_ret_content" "5.9.2" "swift reads .tool-versions"
rm -f .tool-versions

# 2. dart segment
touch pubspec.yaml
zline_segment_dart
assert_eq "$_zline_ret_content" "dart" "dart detects pubspec.yaml"
assert_eq "$_zline_ret_fg" "12" "dart uses color 12"
rm -f pubspec.yaml

print "dart 3.3.0" > .tool-versions
zline_segment_dart
assert_eq "$_zline_ret_content" "3.3.0" "dart reads .tool-versions"
rm -f .tool-versions

# 3. julia segment
touch Project.toml
zline_segment_julia
assert_eq "$_zline_ret_content" "jl" "julia detects Project.toml"
assert_eq "$_zline_ret_fg" "13" "julia uses color 13"
rm -f Project.toml

print "julia 1.10.2" > .tool-versions
zline_segment_julia
assert_eq "$_zline_ret_content" "1.10.2" "julia reads .tool-versions"
rm -f .tool-versions

# 4. ocaml segment
touch dune-project
zline_segment_ocaml
assert_eq "$_zline_ret_content" "ml" "ocaml detects dune-project"
assert_eq "$_zline_ret_fg" "11" "ocaml uses color 11"
rm -f dune-project

print "ocaml 5.1.1" > .tool-versions
zline_segment_ocaml
assert_eq "$_zline_ret_content" "5.1.1" "ocaml reads .tool-versions"
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
assert_eq "$all_documented" "1" "All 58 registered segments documented in man/man1/zline.1"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 28 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
