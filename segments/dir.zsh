zmodload -F zsh/zutil b:zparseopts 2>/dev/null

typeset -g _zline_dir_cache_pwd=""
typeset -g _zline_dir_cache_opts=""
typeset -g _zline_dir_cache_res=""

_zline_find_git_root() {
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

_zline_dir_format_path() {
  local raw="$1"
  local shorten="${2:-0}"
  local keep_last="${3:-1}"
  local anchor="$4"
  local -a in_aliases=("${(@P)5}")

  local p="${raw/#$HOME/~}"
  if [[ "$p" == "~" || "$p" == "/" || -z "$p" ]]; then
    REPLY="$p"
    return 0
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
  local -A opts=()
  local -a alias_arr=()
  zparseopts -E -D -A opts -K \
    -color:=opts -fg:=opts -bg:=opts -icon:=opts \
    -shorten:=opts -keep-last:=opts -anchor:=opts \
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
    _zline_dir_format_path "$PWD" \
      "${opts[--shorten]:-0}" \
      "${opts[--keep-last]:-1}" \
      "${opts[--anchor]:-none}" \
      alias_arr

    _zline_ret_content="$REPLY"
    _zline_dir_cache_pwd="$PWD"
    _zline_dir_cache_opts="$opts_key"
    _zline_dir_cache_res="$_zline_ret_content"
  fi

  if (( _zline_osc_hyperlinks == 1 )); then
    _zline_osc_hyperlink "file://${HOST:-localhost}${PWD}" "$_zline_ret_content"
    _zline_ret_content="$REPLY"
  fi

  _zline_ret_fg="${opts[--color]:-${opts[--fg]:-4}}"
  _zline_ret_bg="${opts[--bg]:-4}"
  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-15}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon=""
  else
    _zline_ret_icon=$'\uF115 '
  fi
}
