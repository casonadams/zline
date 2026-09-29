#!/usr/bin/env zsh
# Test suite for Slice 37: Extended Polyglot Ecosystems & Next-Gen Tooling
# (clojure, erlang, perl, r, solidity, mise, jj, meson, bazel)

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

print -P "%F{14}Running Slice 37 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice32.XXXXXX")"
cd "$test_dir"

# 1. Clojure
touch deps.edn
zline_segment_clojure
assert_eq "$_zline_ret_content" "clj" "clojure detects deps.edn"
assert_eq "$_zline_ret_fg" "10" "clojure uses default color 10"
rm -f deps.edn

# 2. Erlang
touch rebar.config
zline_segment_erlang
assert_eq "$_zline_ret_content" "erl" "erlang detects rebar.config"
assert_eq "$_zline_ret_fg" "9" "erlang uses default color 9"
rm -f rebar.config

# 3. Perl
touch cpanfile
zline_segment_perl
assert_eq "$_zline_ret_content" "pl" "perl detects cpanfile"
assert_eq "$_zline_ret_fg" "12" "perl uses default color 12"
rm -f cpanfile

# 4. R
touch DESCRIPTION
zline_segment_r
assert_eq "$_zline_ret_content" "r" "r detects DESCRIPTION"
assert_eq "$_zline_ret_fg" "12" "r uses default color 12"
rm -f DESCRIPTION

# 5. Solidity
touch foundry.toml
zline_segment_solidity
assert_eq "$_zline_ret_content" "sol" "solidity detects foundry.toml"
assert_eq "$_zline_ret_fg" "8" "solidity uses default color 8"
rm -f foundry.toml

# 6. Mise
touch mise.toml
zline_segment_mise
assert_eq "$_zline_ret_content" "mise" "mise detects mise.toml"
assert_eq "$_zline_ret_fg" "11" "mise uses default color 11"
rm -f mise.toml

# 7. Jujutsu (jj)
mkdir -p .jj
zline_segment_jj
assert_eq "$_zline_ret_content" "jj" "jj detects .jj directory"
assert_eq "$_zline_ret_fg" "13" "jj uses default color 13"
rm -rf .jj

# 8. Meson
cat << 'EOF' > meson.build
project('super_lib', 'c')
EOF
zline_segment_meson
assert_eq "$_zline_ret_content" "super_lib" "meson extracts project name from meson.build"
assert_eq "$_zline_ret_fg" "14" "meson uses default color 14"
rm -f meson.build

# 9. Bazel
touch BUILD.bazel
zline_segment_bazel
assert_eq "$_zline_ret_content" "bazel" "bazel detects BUILD.bazel"
assert_eq "$_zline_ret_fg" "10" "bazel uses default color 10"
rm -f BUILD.bazel

# 10. Documentation completeness
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

print -P "\n%F{14}Slice 37 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
