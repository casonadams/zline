#!/usr/bin/env zsh
# Test suite: right-prompt width budgeting across resizes and prompt-escape safety

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

print -P "%F{14}Running Resize & Escaping Tests:%f"

# 1. Right prompt width budget matches the placement rule at every width
zline style lean
zline_left=( 'text "LEFT"' )
zline_right=( 'text "RIGHT"' )
zline init
_zline_visual_len "$PROMPT"; typeset -i left_w=$REPLY
typeset -i right_w=5
typeset -i fits_at=$(( left_w + right_w + 2 ))
COLUMNS=$(( fits_at - 1 )); zline_render
assert_eq "$RPROMPT" "" "right prompt dropped one column below the fit threshold"
COLUMNS=$fits_at; zline_render
assert_eq "$RPROMPT" "%F{7}RIGHT%f" "right prompt kept exactly at the fit threshold (no budget/drop mismatch)"

# 2. ZLE_RPROMPT_INDENT widens the reserved margin
ZLE_RPROMPT_INDENT=3
COLUMNS=$fits_at; zline_render
assert_eq "$RPROMPT" "" "ZLE_RPROMPT_INDENT=3 reserves extra columns"
COLUMNS=$(( fits_at + 2 )); zline_render
assert_eq "$RPROMPT" "%F{7}RIGHT%f" "right prompt returns once the larger indent fits"
unset ZLE_RPROMPT_INDENT

# 3. Overflow drops from the left, keeping the rightmost segments
zline_left=( 'text "L"' )
zline_right=( 'text "AAAA"' 'text "BBBB"' 'text "CCCC"' )
zline_compile
_zline_visual_len "${PROMPT}"
COLUMNS=17; zline_render
assert_eq "$RPROMPT" "%F{7}BBBB%f %F{7}CCCC%f" "two rightmost segments survive when three do not fit"
COLUMNS=11; zline_render
assert_eq "$RPROMPT" "%F{7}CCCC%f" "single rightmost segment survives on very narrow width"
COLUMNS=5; zline_render
assert_eq "$RPROMPT" "" "no right prompt when nothing fits"

# 4. Multi-line: right prompt falls back to the (short) input line instead of vanishing
zline_left=( 'text "LONG_TOP_LINE_CONTENT"' newline prompt_char )
zline_right=( 'text "RIGHTSIDE"' )
zline_compile
unset COLUMNS; zline_render
_zline_visual_len "${PROMPT%%$'\n'*}"; typeset -i top_w=$REPLY
COLUMNS=$(( top_w + 5 )); zline_render
assert_eq "$RPROMPT" "%F{7}RIGHTSIDE%f" "right prompt placed on input line when top line has no room"
COLUMNS=$(( top_w + 5 + 11 + 4 )); zline_render
assert_eq "$RPROMPT" "" "right prompt merged into the top line when it fits there"
unset COLUMNS

# 5. Hostile text from the filesystem cannot inject prompt escapes
typeset tmp_base
tmp_base="$(mktemp -d "${TMPDIR:-/tmp}/zline-esc.XXXXXX")"
typeset hostile="${tmp_base%/}/50%F{1}x %n"
mkdir -p "$hostile"
() {
  local orig="$PWD"
  cd "$hostile"
  zline_left=( dir )
  zline_right=()
  zline_compile
  COLUMNS=100 zline_render
  local rendered="${(%)PROMPT}"
  local -i ok=0
  [[ "$rendered" == *'50%F{1}x %n'* ]] && ok=1
  assert_eq "$ok" "1" "directory name with percent escapes renders literally"

  setopt promptsubst
  local hostile_sub="${tmp_base%/}/\$(echo PWNED)"
  mkdir -p "$hostile_sub"
  cd "$hostile_sub"
  COLUMNS=100 zline_render
  local expanded
  expanded="$(print -rP -- "$PROMPT")"
  ok=0
  [[ "$expanded" == *'$(echo PWNED)'* ]] && ok=1
  assert_eq "$ok" "1" "directory named with command substitution is shown literally under promptsubst"
  unsetopt promptsubst
  cd "$orig"
}
rm -rf "$tmp_base"

# 6. Environment-derived segment text is escaped too
typeset -x VIRTUAL_ENV="/tmp/env-50%F{1}x"
zline_left=( venv )
zline_compile
COLUMNS=100 zline_render
typeset -i env_ok=0
[[ "$PROMPT" == *'env-50%%F{1}x'* ]] && env_ok=1
assert_eq "$env_ok" "1" "virtualenv name with percent is escaped in the prompt"
unset VIRTUAL_ENV

print -P "\n%F{14}Resize & Escaping Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
