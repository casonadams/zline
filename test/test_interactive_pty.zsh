#!/usr/bin/env zsh
# Interactive behaviors that only exist inside a running line editor, driven through a pty:
# resize re-render, transient widget installation and deferred redraw during isearch.

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

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

print -P "%F{14}Running Interactive PTY Tests:%f"

if ! zmodload zsh/zpty 2>/dev/null; then
  print -P "  %F{11}skipped%f (zsh/zpty unavailable)"
  exit 0
fi
zmodload -F zsh/datetime p:EPOCHREALTIME

typeset tmp_dir
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/zline-pty.XXXXXX")"
mkdir -p "${tmp_dir}/repo/.git"
print -r -- "ref: refs/heads/main" > "${tmp_dir}/repo/.git/HEAD"
typeset log="${tmp_dir}/render.log"
typeset staged="${tmp_dir}/staged"
print 1 > "$staged"

cat > "${tmp_dir}/.zshrc" <<EOF
PS1='> '
source "${REPO_ROOT}/zline.zsh"
_zline_git_provider_slow() { sleep 1.5; print -r -- "\$1:git:main:\$(<"${staged}"):0:0:0:0:0:\$2" }
_zline_git_provider=slow
zline preset lean --no-osc --ascii --transient
zline_left=( dir git )
zline_right=()
zline init
_zline_test_log() { local z=0; zle 2>/dev/null && z=1; print -r -- "ZLE=\$z COLS=\${COLUMNS} PROMPT=\${PROMPT}" >> "${log}" }
zline_hook add post_render _zline_test_log
EOF

typeset pty_out=""
pty_drain() {
  local -F end=$(( EPOCHREALTIME + $1 ))
  local chunk
  while (( EPOCHREALTIME < end )); do
    if zpty -r -t zl chunk 2>/dev/null; then
      pty_out+="$chunk"
    else
      sleep 0.05
    fi
  done
}

typeset saved_zdotdir="$ZDOTDIR" saved_term="$TERM"
export ZDOTDIR="$tmp_dir" TERM="xterm-256color"
cd "${tmp_dir}/repo"
zpty zl 'stty cols 80 rows 24; exec zsh -i'
export TERM="$saved_term"
if [[ -n "$saved_zdotdir" ]]; then export ZDOTDIR="$saved_zdotdir"; else unset ZDOTDIR; fi

# 1. Transient integration is installed in the live line editor
pty_drain 1.2
zpty -w zl 'print -r -- "W=${widgets[zle-line-finish]}"'
pty_drain 0.8
typeset -i widget_ok=0
[[ "$pty_out" == *"W=user:_zline_transient_line_finish"* ]] && widget_ok=1
assert_eq "$widget_ok" "1" "transient prompt widget is installed in the line editor"

# 2. A resize at the idle prompt re-renders inside the line editor with the new width
: > "$log"
zpty -w zl 'stty cols 61; { sleep 0.5; kill -WINCH $$ } &!'
pty_drain 1.8
typeset -i resized=0
[[ "$(<"$log")" == *"ZLE=1 COLS=61"* ]] && resized=1
assert_eq "$resized" "1" "terminal resize triggers an in-editor re-render with the new column count"

# 3. Cached git details stay visible at the next prompt, then the async update redraws it
print 9 > "$staged"
: > "$log"
zpty -w zl 'cd .'
pty_drain 0.6
typeset -i stale_shown=0
[[ "$(<"$log")" == *"+1"* && "$(<"$log")" != *"+9"* ]] && stale_shown=1
assert_eq "$stale_shown" "1" "previous git details are shown immediately while the refresh runs"
pty_drain 2.5
typeset -i redrawn=0
[[ "$(<"$log")" == *"ZLE=1 "*"+9"* ]] && redrawn=1
assert_eq "$redrawn" "1" "async git reply redraws the idle prompt without a keypress"

zpty -d zl 2>/dev/null
cd /
rm -rf "$tmp_dir"

print -P "\n%F{14}Interactive PTY Summary: %F{10}${passed} passed%f, %F{9}${failed} failed%f"

if (( failed > 0 )); then
  exit 1
fi
