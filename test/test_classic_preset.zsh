#!/usr/bin/env zsh
# Test suite: classic preset, soft separators between same-background segments

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

print -P "%F{14}Running Classic Preset Tests:%f"

_zline_osc=0
_zline_mode="nerdfont"
_zline_icons=1

# 1. Same-background neighbours get the thin separator, different ones the solid arrow
zline preset powerline --no-osc
zline_left=( 'text --bg 8 --fg 7 a' 'text --bg 8 --fg 7 b' 'text --bg 4 --fg 7 c' )
zline_right=( 'text --bg 8 --fg 7 a' 'text --bg 8 --fg 7 b' 'text --bg 4 --fg 7 c' )
zline_compile
_zline_render_left
typeset left_out="$REPLY"
assert_eq "${left_out//[^$'\uE0B1']/}" $'\uE0B1' "left: one thin separator between equal-bg segments"
assert_eq "${left_out//[^$'\uE0B0']/}" $'\uE0B0\uE0B0' "left: solid arrows at bg change and closing"
_zline_render_right
typeset right_out="$REPLY"
assert_eq "${right_out//[^$'\uE0B3']/}" $'\uE0B3' "right: one thin separator between equal-bg segments"
assert_eq "${right_out//[^$'\uE0B2']/}" $'\uE0B2\uE0B2' "right: solid arrows at start and bg change"

# 2. _zline_sep_soft_color overrides the segment foreground for the thin separator
_zline_sep_soft_color="5"
_zline_render_left
typeset has_soft_color=0
[[ "$REPLY" == *"%F{5}"$'\uE0B1'* ]] && has_soft_color=1
assert_eq "$has_soft_color" "1" "soft separator uses _zline_sep_soft_color"
_zline_sep_soft_color=""

# 3. classic preset: frame, connecting line, grey blocks
zline preset classic --no-osc
assert_eq "$_zline_frame" "full" "classic enables the full frame"
assert_eq "$_zline_connect_char" "─" "classic enables the connecting line"
assert_eq "$_zline_style" "powerline" "classic reuses the powerline renderer"

# 4. Switching presets resets what classic set
zline preset lean --no-osc
assert_eq "$_zline_frame" "" "frame is cleared when switching away from classic"
assert_eq "$_zline_sep_soft_color" "" "soft separator color is cleared when switching away from classic"
assert_eq "$_zline_connect_char" "" "connecting line is cleared when switching away from classic"

# 5. git foreground follows status when bg is fixed, stays 0 when bg is derived
_zline_git_cache_valid=1
_zline_git_cache_dir="$PWD"
_zline_git_cache_branch="main"
_zline_git_cache_staged=0 _zline_git_cache_unstaged=0 _zline_git_cache_untracked=0
_zline_git_cache_ahead=0 _zline_git_cache_behind=0 _zline_git_cache_conflicts=0
_zline_style="powerline"
_zline_set_style_separators
zline_segment_git --bg 8 --clean 2
assert_eq "$_zline_ret_fg" "2" "git --bg without --fg uses the status color as foreground"
zline_segment_git --clean 2
assert_eq "$_zline_ret_fg" "0" "git without --bg keeps dark foreground on status-colored block"
zline_segment_git --bg 8 --fg 15 --clean 2
assert_eq "$_zline_ret_fg" "15" "git explicit --fg wins"

print -P "\n%F{14}Classic Preset Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"
(( failed == 0 )) || exit 1
