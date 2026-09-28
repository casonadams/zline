#!/usr/bin/env zsh
# Test suite for Slice 23: Modern Developer Environments and Universal Runtime Detection

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

print -P "%F{14}Running Slice 23 Tests:%f"

typeset test_dir
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline_test_slice23.XXXXXX")"
cd "$test_dir"

# 1. nix_shell segment
IN_NIX_SHELL="pure"
zline_segment_nix_shell
assert_eq "$_zline_ret_content" "pure" "nix_shell detects pure nix shell"
assert_eq "$_zline_ret_fg" "14" "nix_shell uses default color 14"

IN_NIX_SHELL="impure"
zline_segment_nix_shell
assert_eq "$_zline_ret_content" "impure" "nix_shell detects impure nix shell"

unset IN_NIX_SHELL
name="my-nix-pkg"
SHLVL=2
NIX_PROFILES="/nix/var/nix/profiles/default"
zline_segment_nix_shell
assert_eq "$_zline_ret_content" "my-nix-pkg" "nix_shell falls back to \$name"
unset name NIX_PROFILES

# 2. direnv segment
DIRENV_DIR="-/tmp/my-project"
zline_segment_direnv
assert_eq "$_zline_ret_content" "my-project" "direnv extracts active directory name"
assert_eq "$_zline_ret_fg" "11" "direnv uses default color 11"
unset DIRENV_DIR

# 3. lua segment
print "5.4.6" > .lua-version
zline_segment_lua
assert_eq "$_zline_ret_content" "5.4.6" "lua segment reads .lua-version"
assert_eq "$_zline_ret_fg" "4" "lua segment uses default color 4"
rm -f .lua-version

print "lua 5.1.5" > .tool-versions
zline_segment_lua
assert_eq "$_zline_ret_content" "5.1.5" "lua segment reads .tool-versions"
rm -f .tool-versions

touch init.lua
zline_segment_lua
assert_eq "$_zline_ret_content" "lua" "lua segment detects init.lua"
rm -f init.lua

# 4. zig segment
print "0.12.0" > .zigversion
zline_segment_zig
assert_eq "$_zline_ret_content" "0.12.0" "zig segment reads .zigversion"
assert_eq "$_zline_ret_fg" "3" "zig segment uses default color 3"
rm -f .zigversion

print "zig 0.11.0" > .tool-versions
zline_segment_zig
assert_eq "$_zline_ret_content" "0.11.0" "zig segment reads .tool-versions"
rm -f .tool-versions

touch build.zig
zline_segment_zig
assert_eq "$_zline_ret_content" "zig" "zig segment detects build.zig"
rm -f build.zig

# 5. Universal .tool-versions fallback in existing runtimes
cat << 'EOF' > .tool-versions
nodejs 20.10.0
rust 1.75.0
golang 1.22.1
ruby 3.3.0
python 3.12.2
php 8.3.1
java 21.0.2
dotnet 8.0.200
EOF

zline_segment_node
assert_eq "$_zline_ret_content" "20.10.0" "node reads .tool-versions"

zline_segment_rust
assert_eq "$_zline_ret_content" "1.75.0" "rust reads .tool-versions"

zline_segment_golang
assert_eq "$_zline_ret_content" "1.22.1" "golang reads .tool-versions"

zline_segment_ruby
assert_eq "$_zline_ret_content" "3.3.0" "ruby reads .tool-versions"

zline_segment_venv
assert_eq "$_zline_ret_content" "3.12.2" "venv/python reads .tool-versions"

zline_segment_php
assert_eq "$_zline_ret_content" "8.3.1" "php reads .tool-versions"

zline_segment_java
assert_eq "$_zline_ret_content" "21.0.2" "java reads .tool-versions"

zline_segment_dotnet
assert_eq "$_zline_ret_content" "8.0.200" "dotnet reads .tool-versions"

rm -f .tool-versions

# 6. Documentation completeness
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

print -P "\n%F{14}Slice 23 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
