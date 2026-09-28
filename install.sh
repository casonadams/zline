#!/bin/sh
# zline installer script

set -e

INSTALL_DIR="${ZLINE_INSTALL_DIR:-$HOME/.zline}"
REPO_URL="https://github.com/casonadams/zline.git"

printf "\033[1;36m==> Installing zline...\033[0m\n"

if [ -d "$INSTALL_DIR" ]; then
  printf "    Updating existing installation at %s...\n" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
  git pull --quiet --ff-only 2>/dev/null || true
else
  printf "    Cloning repository to %s...\n" "$INSTALL_DIR"
  git clone --quiet --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

if command -v zsh >/dev/null 2>&1; then
  printf "    Pre-compiling Zsh wordcode (.zwc)...\n"
  zsh -c "source '${INSTALL_DIR}/zline.zsh' && zline compile" 2>/dev/null || true
fi

ZSHRC="$HOME/.zshrc"
LINE_TO_ADD="source ${INSTALL_DIR}/zline.zsh"

if [ -f "$ZSHRC" ]; then
  if ! grep -q "zline.zsh" "$ZSHRC" 2>/dev/null; then
    printf "\n# zline prompt engine\n%s\nzline preset powerline --transient\nzline init\n" "$LINE_TO_ADD" >> "$ZSHRC"
    printf "    Added zline configuration to %s\n" "$ZSHRC"
  else
    printf "    zline is already configured in %s\n" "$ZSHRC"
  fi
else
  printf "# zline prompt engine\n%s\nzline preset powerline --transient\nzline init\n" "$LINE_TO_ADD" >> "$ZSHRC"
  printf "    Created %s with zline configuration\n" "$ZSHRC"
fi

printf "\033[1;32m==> zline installed successfully!\033[0m\n"
printf "    Restart your terminal or run: \033[1;34msource ~/.zshrc\033[0m\n\n"
