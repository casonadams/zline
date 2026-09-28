zline_update() {
  if [[ ! -d "${ZLINE_DIR}/.git" ]]; then
    print -u2 -P "%F{9}zline: cannot update (installation at ${ZLINE_DIR} is not a git repository)%f"
    return 1
  fi

  print -P "%F{14}%B==> Updating zline...%b%f"

  local pull_out
  if ! pull_out=$(git -C "${ZLINE_DIR}" pull --ff-only 2>&1); then
    print -u2 -P "%F{9}zline update failed: ${pull_out}%f"
    return 1
  fi

  print -r -- "$pull_out"

  if (( $+functions[zline_compile_all] )); then
    zline_compile_all
  fi

  print -P "\n%F{10}%B==> zline updated successfully!%b%f"
  print -P "    Restart your shell or run: %Bsource ~/.zshrc%b\n"
}
