typeset -gA _ZLINE_P10K_SEG_MAP=(
  dir dir
  vcs git
  status status
  command_execution_time exec_time
  prompt_char prompt_char
  virtualenv venv
  anaconda venv
  pyenv venv
  nodenv node
  nvm node
  node_version node
  kubecontext k8s
  time time
  background_jobs jobs
  aws aws
  rust_version rust
  go_version golang
  terraform terraform
  package package
  newline newline
)

_zline_migrate_extract_elements() {
  local p10k_file="$1"
  local var_name="$2"
  local target_var="$3"

  local in_block=0
  local line=""
  local word=""
  local -a items=()

  while IFS= read -r line; do
    if [[ "$line" == *"${var_name}="* ]]; then
      in_block=1
      line="${line#*\(}"
    fi

    if (( in_block == 1 )); then
      if [[ "$line" == *")"* ]]; then
        line="${line%%\)*}"
        in_block=0
      fi
      for word in ${(z)line}; do
        [[ "$word" == \#* ]] && break
        word="${word//[\'\"]}"
        [[ -n "$word" ]] && items+=("$word")
      done
      (( in_block == 0 )) && break
    fi
  done < "$p10k_file"

  set -A "$target_var" "${items[@]}"
}

zline_migrate() {
  local p10k_file="${1:-${HOME}/.p10k.zsh}"
  local out_file="$2"

  if [[ ! -r "$p10k_file" ]]; then
    print -u2 -P "%F{9}zline: p10k configuration file not found at: ${p10k_file}%f"
    return 1
  fi

  typeset -ga _p10k_left_raw=()
  typeset -ga _p10k_right_raw=()
  _zline_migrate_extract_elements "$p10k_file" "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS" _p10k_left_raw
  _zline_migrate_extract_elements "$p10k_file" "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" _p10k_right_raw

  local style="powerline"
  if grep -q "POWERLEVEL9K_STYLE=lean" "$p10k_file" 2>/dev/null || grep -q "p10k-lean" "$p10k_file" 2>/dev/null; then
    style="lean"
  elif grep -q "POWERLEVEL9K_STYLE=rainbow" "$p10k_file" 2>/dev/null || grep -q "p10k-rainbow" "$p10k_file" 2>/dev/null; then
    style="rainbow"
  elif grep -q "POWERLEVEL9K_STYLE=pure" "$p10k_file" 2>/dev/null || grep -q "p10k-pure" "$p10k_file" 2>/dev/null; then
    style="pure"
  fi

  local trans_flag=""
  if grep -E -q "POWERLEVEL9K_TRANSIENT_PROMPT=(always|true)" "$p10k_file" 2>/dev/null; then
    trans_flag=" --transient"
  fi

  local -a left_zline=()
  local seg
  for seg in "${_p10k_left_raw[@]}"; do
    local mapped="${_ZLINE_P10K_SEG_MAP[$seg]}"
    if [[ -n "$mapped" ]]; then
      if [[ "$mapped" == "dir" ]]; then
        left_zline+=("  'dir --shorten 1 --anchor git'")
      elif [[ "$mapped" == "git" ]]; then
        left_zline+=("  'git --clean 2 --dirty 3'")
      elif [[ "$mapped" == "newline" || "$mapped" == "prompt_char" ]]; then
        left_zline+=("  $mapped")
      else
        left_zline+=("  '$mapped'")
      fi
    fi
  done

  local -a right_zline=()
  for seg in "${_p10k_right_raw[@]}"; do
    local mapped="${_ZLINE_P10K_SEG_MAP[$seg]}"
    if [[ -n "$mapped" ]]; then
      if [[ "$mapped" == "status" ]]; then
        right_zline+=("  'status --hide-zero'")
      elif [[ "$mapped" == "exec_time" ]]; then
        right_zline+=("  'exec_time --min 2'")
      else
        right_zline+=("  '$mapped'")
      fi
    fi
  done

  local generated="# Migrated automatically from ${p10k_file:t} to zline
zline preset ${style}${trans_flag}

zline_left=(
${(F)left_zline}
)

zline_right=(
${(F)right_zline}
)

zline init"

  if [[ -n "$out_file" ]]; then
    print -r -- "$generated" >! "$out_file"
    print -P "  %F{10}✓%f Migrated p10k config saved to %B${out_file}%b"
  else
    print -P "%F{14}%B============================================================%b%f"
    print -P "%F{15}%B           Migrated zline Configuration from p10k           %b%f"
    print -P "%F{14}%B============================================================%b%f\n"
    print -r -- "$generated"
    print -P "\n%F{14}%B============================================================%b%f"
  fi
}
