#!/usr/bin/env zsh
# Test suite for man page validity and manpath resolution

set -e

SCRIPT_DIR="${${(%):-%x}:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

MAN_FILE="${REPO_ROOT}/man/man1/zline.1"
[[ -f "$MAN_FILE" ]] || { print -u2 "FAIL: man/man1/zline.1 missing"; exit 1; }

FIRST_LINE="$(head -n 1 "$MAN_FILE")"
[[ "$FIRST_LINE" == *".TH ZLINE 1"* ]] || {
  print -u2 "FAIL: unexpected troff header: $FIRST_LINE"
  exit 1
}

source "${REPO_ROOT}/zline.zsh"

if (( ! ${manpath[(Ie)${ZLINE_DIR}/man]} )); then
  print -u2 "FAIL: ZLINE_DIR/man not added to manpath"
  exit 1
fi

if (( $+commands[man] )); then
  RESOLVED_MAN="$(man -M "${ZLINE_DIR}/man" -w zline 2>/dev/null || true)"
  if [[ -n "$RESOLVED_MAN" ]]; then
    [[ "$RESOLVED_MAN" == *"$MAN_FILE"* ]] || {
      print -u2 "FAIL: man -w zline resolved to unexpected path ($RESOLVED_MAN)"
      exit 1
    }
  fi
fi

print -P "  %F{10}✓%f man page troff header, manpath registration, and man resolution"
