#!/usr/bin/env zsh
# Test suite for Slice 1: Core Engine, Event Hooks & Base16 Color Subsystem

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

print -P "%F{14}Running Slice 1 Tests:%f"

# 1. Base16 color tests
_zline_color_code "green"
assert_eq "$REPLY" "2" "Color name 'green' maps to code 2"

_zline_color_code "bright-cyan"
assert_eq "$REPLY" "14" "Color name 'bright-cyan' maps to code 14"

_zline_color_code "none"
assert_eq "$REPLY" "reset" "Color 'none' maps to 'reset'"

_zline_fg "green"
assert_eq "$REPLY" "%F{2}" "Foreground escape for green is %F{2}"

_zline_fg "none"
assert_eq "$REPLY" "%f" "Foreground escape for none is %f"

_zline_bg "blue"
assert_eq "$REPLY" "%K{4}" "Background escape for blue is %K{4}"

_zline_bg "none"
assert_eq "$REPLY" "%k" "Background escape for none is %k"

_zline_fg "#ff0088"
assert_eq "$REPLY" "%F{#ff0088}" "Hex foreground color passes through"

_zline_wrap_raw $'\e[1m'
assert_eq "$REPLY" "%{"$'\e[1m'"%}" "Raw sequence wrapped in %{...%}"

# 2. Visual length calculator
_zline_visual_len "hello"
assert_eq "$REPLY" "5" "Visual length of 'hello' is 5"

_zline_visual_len "%F{10}colored text%f"
assert_eq "$REPLY" "12" "Visual length ignores %F / %f escapes"

_zline_visual_len ""
assert_eq "$REPLY" "0" "Visual length of empty string is 0"

# 3. Hook system
typeset -g _test_hook_val=0
_test_hook_cb1() { _test_hook_val=$(( _test_hook_val + 1 )); }
_test_hook_cb2() { _test_hook_val=$(( _test_hook_val + 10 )); }

zline_hook add precmd _test_hook_cb1
zline_hook add precmd _test_hook_cb2
zline_hook run precmd
assert_eq "$_test_hook_val" "11" "Hooks execute in registered order"

zline_hook remove precmd _test_hook_cb1
_test_hook_val=0
zline_hook run precmd
assert_eq "$_test_hook_val" "10" "Removed hook is no longer executed"

# 4. Render and Style engine
zline_segment_mock_dir() {
  _zline_ret_content="~/test/dir"
  _zline_ret_fg="15"
  _zline_ret_bg="4"
  _zline_ret_icon=" "
}

zline_segment_mock_git() {
  _zline_ret_content="main"
  _zline_ret_fg="0"
  _zline_ret_bg="2"
  _zline_ret_icon=" "
}

# Test Lean style
zline style lean
zline_left=(mock_dir mock_git)
zline_right=()
zline init

assert_eq "$PROMPT" "%F{15} %f %F{15}~/test/dir%f %F{0} %f %F{0}main%f " "Lean prompt renders segments with spaces"

# Test Powerline style
local u_sep=$'\uE0B0'
zline style powerline
zline init
# Expected: Segment 1 (bg 4), separator (fg 4, bg 2), segment 2 (bg 2), closing separator (fg 2, bg none)
assert_eq "$PROMPT" "%K{4}%F{15}   ~/test/dir %f%K{2}%F{4}${u_sep}%f%K{2}%F{0}   main %f%k%F{2}${u_sep}%f " "Powerline prompt renders powerline separators between background blocks"

# Test Multiline layout
zline_left=(mock_dir newline mock_git)
zline init
assert_eq "$PROMPT" "%K{4}%F{15}   ~/test/dir %f%k%F{4}${u_sep}%f"$'\n'"%K{2}%F{0}   main %f%k%F{2}${u_sep}%f " "Multiline layout closes powerline before newline and restarts cleanly"

# Test Right prompt in powerline
local r_sep=$'\uE0B2'
zline_left=(mock_dir)
zline_right=(mock_git)
zline init
assert_eq "$RPROMPT" "%k%F{2}${r_sep}%f%K{2}%F{0}   main %f%k" "Right prompt in powerline renders reverse separator"

print -P "\n%F{14}Slice 1 Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
