zline_compile_file() {
  local file="$1"
  local zwc="${file}.zwc"

  if [[ ! -f "$file" ]]; then
    return 1
  fi

  if [[ -f "$zwc" && "$zwc" -nt "$file" ]]; then
    return 0
  fi

  zcompile -R "$zwc" "$file" 2>/dev/null
}

zline_compile_all() {
  local -i compiled=0
  local file

  for file in "${ZLINE_DIR}"/zline.zsh "${ZLINE_DIR}"/zline.plugin.zsh "${ZLINE_DIR}"/completion/_zline(N) "${ZLINE_DIR}"/lib/*.zsh(N) "${ZLINE_DIR}"/segments/*.zsh(N) "${ZLINE_DIR}"/themes/*.zsh(N); do
    if zline_compile_file "$file"; then
      (( compiled += 1 ))
    fi
  done

  print -P "  %F{10}✓%f Pre-compiled ${compiled} files to Zsh wordcode (.zwc)"
}

zline_clean_compiled() {
  local -i removed=0
  local file

  for file in "${ZLINE_DIR}"/**/*.zwc(N) "${ZLINE_DIR}"/**/*.zwc.old(N); do
    rm -f "$file" 2>/dev/null && (( removed += 1 ))
  done

  print -P "  %F{10}✓%f Cleaned ${removed} compiled wordcode (.zwc) files"
}
