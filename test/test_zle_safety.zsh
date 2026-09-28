#!/usr/bin/env zsh
# Audit test: Verifies ZLE line editor cursor safety, escape isolation, and zero cursor drift

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

print -P "%F{14}Running ZLE Safety & Cursor Alignment Audit:%f"

# 1. Audit all 8 presets for visual width and line integrity
typeset -a presets=(powerline lean rainbow pure catppuccin tokyonight nord gruvbox)
local p
for p in "${presets[@]}"; do
  zline preset "$p" --no-osc
  zline init
  COLUMNS=100 zline_render

  # Check top line visual length
  local top="${PROMPT%%$'\n'*}"
  _zline_visual_len "$top"
  local -i top_len=$REPLY
  local -i top_ok=0
  (( top_len > 0 && top_len <= 100 )) && top_ok=1
  assert_eq "$top_ok" "1" "Preset '${p}' top line has valid visual column width (${top_len} cols)"

  # Check bottom line visual length
  local bot="${PROMPT#*$'\n'}"
  _zline_visual_len "$bot"
  local -i bot_len=$REPLY
  local -i bot_ok=0
  (( bot_len > 0 && bot_len < 20 )) && bot_ok=1
  assert_eq "$bot_ok" "1" "Preset '${p}' input line has minimal visual cursor width (${bot_len} cols)"
done

# 2. OSC 133 & OSC 8 zero-width isolation audit
zline preset powerline --hyperlinks
_zline_osc=1
_zline_osc_hyperlinks=1
zline init
COLUMNS=100 zline_render

local top_osc="${PROMPT%%$'\n'*}"
_zline_visual_len "$top_osc"
local -i osc_len=$REPLY

_zline_osc=0
_zline_osc_hyperlinks=0
zline_render
local top_plain="${PROMPT%%$'\n'*}"
_zline_visual_len "$top_plain"
local -i plain_len=$REPLY

assert_eq "$osc_len" "$plain_len" "OSC 133 and OSC 8 sequences do not inflate ZLE visual column count"

print -P "\n%F{14}ZLE Safety Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
