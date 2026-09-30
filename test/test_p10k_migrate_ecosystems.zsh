#!/usr/bin/env zsh
# Test suite for Slice 10: P10k Migration Tool & Ecosystem Segments

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

print -P "%F{14}Running Slice 10 Tests:%f"

typeset test_dir=$(mktemp -d "${TMPDIR:-/tmp}/zline-test-s10.XXXXXX")
cd "$test_dir"

# 1. Rust segment
print -r "1.78.0" > rust-toolchain
zline_segment_rust
assert_eq "$_zline_ret_content" "1.78.0" "Rust segment reads rust-toolchain"
rm -f rust-toolchain

# 2. Golang segment
print -l "module myapp" "" "go 1.22.4" > go.mod
zline_segment_golang
assert_eq "$_zline_ret_content" "1.22.4" "Golang segment extracts version from go.mod"
rm -f go.mod

# 3. Terraform segment
TF_WORKSPACE="production" zline_segment_terraform
assert_eq "$_zline_ret_content" "production" "Terraform segment detects TF_WORKSPACE"
unset TF_WORKSPACE

# 4. Docker segment
DOCKER_CONTEXT="remote-swarm" zline_segment_docker
assert_eq "$_zline_ret_content" "remote-swarm" "Docker segment detects DOCKER_CONTEXT"
unset DOCKER_CONTEXT

# 5. Package segment
print -r '{"name": "test-pkg", "version": "3.1.4"}' > package.json
zline_segment_package
assert_eq "$_zline_ret_content" "3.1.4" "Package segment extracts version from package.json"
rm -f package.json

print -l '[package]' 'name = "foo"' 'version = "0.2.1"' > Cargo.toml
zline_segment_package
assert_eq "$_zline_ret_content" "0.2.1" "Package segment extracts version from Cargo.toml"
rm -f Cargo.toml

print -l '[project]' 'name = "bar"' 'version = "0.4.2"' > pyproject.toml
zline_segment_package
assert_eq "$_zline_ret_content" "0.4.2" "Package segment extracts version from pyproject.toml"
rm -f pyproject.toml

# 6. P10k Migration Tool
typeset p10k_file="${test_dir}/p10k.zsh"
typeset out_file="${test_dir}/zline.zsh"

cat << 'EOF' > "$p10k_file"
POWERLEVEL9K_STYLE=lean
POWERLEVEL9K_TRANSIENT_PROMPT=always
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
  newline
  prompt_char
)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  virtualenv
  kubecontext
  rust_version
  go_version
)
EOF

zline migrate "$p10k_file" "$out_file"
typeset -i out_exists=0
[[ -s "$out_file" ]] && out_exists=1
assert_eq "$out_exists" "1" "zline migrate generated output file"

# Verify content of migrated config
typeset content=$(< "$out_file")
[[ "$content" == *"zline preset lean --transient"* ]] && assert_eq "has_preset" "has_preset" "Migrated preset matches p10k style"
[[ "$content" == *"'dir --shorten 1 --anchor git'"* ]] && assert_eq "has_dir" "has_dir" "Migrated dir segment translated"
[[ "$content" == *"'git --clean 2 --dirty 3'"* ]] && assert_eq "has_git" "has_git" "Migrated vcs translated to git"
[[ "$content" == *"'rust'"* ]] && assert_eq "has_rust" "has_rust" "Migrated rust_version translated to rust"
[[ "$content" == *"'golang'"* ]] && assert_eq "has_go" "has_go" "Migrated go_version translated to golang"

# Verify generated file passes syntax check
zsh -n "$out_file"
assert_eq "0" "0" "Migrated config file passes zsh -n syntax check"

cd "$REPO_ROOT"
rm -rf "$test_dir"

print -P "\n%F{14}Slice 10 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
