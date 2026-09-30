zmodload -F zsh/zutil b:zparseopts 2>/dev/null

typeset -g _zline_dir_cache_pwd=""
typeset -g _zline_dir_cache_opts=""
typeset -g _zline_dir_cache_res=""

_zline_find_git_root() {
  emulate -L zsh
  local cur="$1"
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    if [[ -e "${cur}/.git" ]]; then
      REPLY="$cur"
      return 0
    fi
    cur="${cur:h}"
  done
  REPLY=""
  return 1
}

_zline_find_project_root() {
  emulate -L zsh
  local cur="$1"
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    if [[ -e "${cur}/.git" || -d "${cur}/.jj" || -f "${cur}/package.json" || -f "${cur}/Cargo.toml" || \
          -f "${cur}/go.mod" || -f "${cur}/pyproject.toml" || -f "${cur}/pom.xml" || \
          -f "${cur}/build.gradle" || -f "${cur}/mix.exs" || -f "${cur}/CMakeLists.txt" || \
          -f "${cur}/Gemfile" || -f "${cur}/composer.json" || -f "${cur}/build.zig" || \
          -f "${cur}/deno.json" || -f "${cur}/bunfig.toml" || -f "${cur}/pubspec.yaml" ]]; then
      REPLY="$cur"
      return 0
    fi
    cur="${cur:h}"
  done
  REPLY=""
  return 1
}

_zline_dir_format_path() {
  emulate -L zsh
  local raw="$1"
  local shorten="${2:-0}"
  local keep_last="${3:-1}"
  local anchor="$4"
  local -a in_aliases=()
  local -i last_n=0
  if [[ "$5" == <-> ]]; then
    last_n="$5"
    in_aliases=("${(@P)6}")
  else
    in_aliases=("${(@P)5}")
    last_n="${6:-0}"
  fi

  local p="${raw/#$HOME/~}"
  if [[ "$p" == "~" || "$p" == "/" || -z "$p" ]]; then
    REPLY="$p"
    return 0
  fi

  if (( last_n > 0 )); then
    local -a raw_parts=("${(s:/:)p}")
    local -a non_empty_parts=("${raw_parts[@]:#}")
    local -i n_parts=${#non_empty_parts}
    if (( n_parts > last_n )); then
      local -a tail_parts=("${non_empty_parts[@]: -${last_n}}")
      if [[ "${non_empty_parts[1]}" == "~" ]]; then
        REPLY="~/.../${(j:/:)tail_parts}"
      else
        REPLY=".../${(j:/:)tail_parts}"
      fi
      return 0
    fi
  fi

  local -A alias_map=()
  local item
  for item in "${in_aliases[@]}"; do
    [[ "$item" == "--alias" ]] && continue
    alias_map[${item%%=*}]="${item#*=}"
  done

  local git_rel=""
  if [[ "$anchor" == "git" ]]; then
    _zline_find_git_root "$raw" || true
    if [[ -n "$REPLY" ]]; then
      git_rel="${REPLY/#$HOME/~}"
    fi
  elif [[ "$anchor" == "project" ]]; then
    _zline_find_project_root "$raw" || true
    if [[ -n "$REPLY" ]]; then
      git_rel="${REPLY/#$HOME/~}"
    fi
  fi

  local -a parts=("${(s:/:)p}")
  local -i total=${#parts}
  local -a out=()
  local -i i
  local cur_path=""

  for (( i = 1; i <= total; i++ )); do
    local part="${parts[i]}"
    if [[ $i -eq 1 && "$part" == "~" ]]; then
      cur_path="~"
      out+=("~")
      continue
    elif [[ -z "$part" ]]; then
      out+=("")
      continue
    fi

    if [[ -z "$cur_path" || "$cur_path" == "/" ]]; then
      cur_path="/$part"
    else
      cur_path="$cur_path/$part"
    fi

    local alias_val="${alias_map[$part]}"
    if [[ -n "$alias_val" ]]; then
      out+=("$alias_val")
      continue
    fi

    if [[ -n "$git_rel" && "$cur_path" == "$git_rel" ]]; then
      out+=("$part")
      continue
    fi

    if (( i > total - keep_last )); then
      out+=("$part")
      continue
    fi

    if (( shorten > 0 )); then
      out+=("${part[1,shorten]}")
    else
      out+=("$part")
    fi
  done

  REPLY="${(j:/:)out}"
}

_zline_dir_on_chpwd() {
  _zline_dir_cache_pwd=""
}

zline_hook add chpwd _zline_dir_on_chpwd

zline_segment_dir() {
  emulate -L zsh
  local -A opts=()
  local -a alias_arr=()
  zparseopts -E -D -A opts -K \
    -color:=opts -fg:=opts -bg:=opts -icon:=opts \
    -readonly-icon:=opts -readonly-color:=opts \
    -shorten:=opts -keep-last:=opts -anchor:=opts \
    -last:=opts -max-depth:=opts \
    -format:=opts -alias+:=alias_arr

  local opts_key="$*|${alias_arr[*]}"
  if [[ "$PWD" == "$_zline_dir_cache_pwd" && "$opts_key" == "$_zline_dir_cache_opts" ]]; then
    _zline_ret_content="$_zline_dir_cache_res"
  elif [[ -n "${opts[--format]}" && $+functions[${opts[--format]}] -eq 1 ]]; then
    "${opts[--format]}" "$PWD"
    _zline_ret_content="$REPLY"
    _zline_dir_cache_pwd="$PWD"
    _zline_dir_cache_opts="$opts_key"
    _zline_dir_cache_res="$_zline_ret_content"
  else
    local ln="${opts[--last]:-${opts[--max-depth]:-0}}"
    _zline_dir_format_path "$PWD" \
      "${opts[--shorten]:-0}" \
      "${opts[--keep-last]:-1}" \
      "${opts[--anchor]:-none}" \
      alias_arr \
      "$ln"

    _zline_ret_content="$REPLY"
    _zline_dir_cache_pwd="$PWD"
    _zline_dir_cache_opts="$opts_key"
    _zline_dir_cache_res="$_zline_ret_content"
  fi

  if (( _zline_osc_hyperlinks == 1 )); then
    _zline_osc_hyperlink "${_zline_osc_host_prefix}${PWD}" "$_zline_ret_content"
    _zline_ret_content="$REPLY"
  fi

  local -i is_readonly=0
  if [[ ! -w "$PWD" ]]; then
    is_readonly=1
  fi

  _zline_ret_fg="${opts[--color]:-${opts[--fg]:-4}}"
  _zline_ret_bg="${opts[--bg]:-4}"

  if (( is_readonly == 1 )); then
    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      _zline_ret_bg="${opts[--readonly-color]:-1}"
      _zline_ret_fg="15"
    else
      _zline_ret_fg="${opts[--readonly-color]:-9}"
    fi
  elif [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif (( is_readonly == 1 )); then
    if [[ -n "${opts[--readonly-icon]}" ]]; then
      _zline_ret_icon="${opts[--readonly-icon]}"
    elif [[ "$_zline_mode" == "ascii" ]]; then
      _zline_ret_icon="[ro] "
    else
      _zline_ret_icon=$'\uF023 '
    fi
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon=""
  else
    _zline_ret_icon=$'\uF115 '
  fi
}
