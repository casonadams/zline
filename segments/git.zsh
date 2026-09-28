typeset -g _zline_git_cache_branch=""
typeset -gi _zline_git_cache_staged=0
typeset -gi _zline_git_cache_unstaged=0
typeset -gi _zline_git_cache_untracked=0
typeset -gi _zline_git_cache_ahead=0
typeset -gi _zline_git_cache_behind=0
typeset -gi _zline_git_cache_conflicts=0
typeset -gi _zline_git_cache_valid=0

_zline_git_read_head() {
  local dir="$1"
  local git_path="${dir}/.git"
  if [[ -f "$git_path" ]]; then
    local line
    read -r line < "$git_path" 2>/dev/null
    if [[ "$line" == "gitdir: "* ]]; then
      local gd="${line#gitdir: }"
      [[ "$gd" != /* ]] && gd="${dir}/${gd}"
      git_path="$gd"
    fi
  fi

  local head_file="${git_path}/HEAD"
  [[ -r "$head_file" ]] || { REPLY=""; return 1; }

  local head
  read -r head < "$head_file" 2>/dev/null
  local branch=""
  if [[ "$head" == "ref: refs/heads/"* ]]; then
    branch="${head#ref: refs/heads/}"
  elif [[ "$head" == "ref: refs/tags/"* ]]; then
    branch="tag:${head#ref: refs/tags/}"
  elif [[ -n "$head" ]]; then
    branch="${head[1,7]}"
  fi

  if [[ -f "${git_path}/MERGE_HEAD" ]]; then
    branch="${branch}|MERGING"
  elif [[ -d "${git_path}/rebase-merge" || -d "${git_path}/rebase-apply" ]]; then
    branch="${branch}|REBASE"
  elif [[ -f "${git_path}/CHERRY_PICK_HEAD" ]]; then
    branch="${branch}|CHERRY-PICK"
  fi

  REPLY="$branch"
  return 0
}

_zline_git_format_details() {
  local -a items=()
  (( _zline_git_cache_conflicts > 0 )) && items+=("x${_zline_git_cache_conflicts}")
  (( _zline_git_cache_staged > 0 )) && items+=("+${_zline_git_cache_staged}")
  (( _zline_git_cache_unstaged > 0 )) && items+=("!${_zline_git_cache_unstaged}")
  (( _zline_git_cache_untracked > 0 )) && items+=("?${_zline_git_cache_untracked}")

  if [[ "$_zline_mode" == "ascii" ]]; then
    (( _zline_git_cache_ahead > 0 )) && items+=("^${_zline_git_cache_ahead}")
    (( _zline_git_cache_behind > 0 )) && items+=("v${_zline_git_cache_behind}")
  else
    (( _zline_git_cache_ahead > 0 )) && items+=($'\u21E1'"${_zline_git_cache_ahead}")
    (( _zline_git_cache_behind > 0 )) && items+=($'\u21E3'"${_zline_git_cache_behind}")
  fi

  REPLY="${(j: :)items}"
}

zline_segment_git() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -clean:=opts -dirty:=opts -ahead:=opts -color:=opts \
    -fg:=opts -bg:=opts -icon:=opts

  _zline_find_git_root "$PWD"
  local git_root="$REPLY"
  if [[ -z "$git_root" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_git_read_head "$git_root"
  local branch="$REPLY"
  [[ -z "$branch" ]] && { _zline_ret_content=""; return 0; }

  _zline_worker_send "git" "$git_root" 2>/dev/null

  local details=""
  local -i is_dirty=0
  if (( _zline_git_cache_valid == 1 )); then
    _zline_git_format_details
    details="$REPLY"
    if (( _zline_git_cache_staged > 0 || _zline_git_cache_unstaged > 0 || _zline_git_cache_untracked > 0 || _zline_git_cache_conflicts > 0 )); then
      is_dirty=1
    fi
  fi

  if [[ -n "$details" ]]; then
    _zline_ret_content="${branch} ${details}"
  else
    _zline_ret_content="${branch}"
  fi

  local clean_col="${opts[--clean]:-2}"
  local dirty_col="${opts[--dirty]:-3}"
  local ahead_col="${opts[--ahead]:-12}"

  local status_col="$clean_col"
  if (( is_dirty == 1 )); then
    status_col="$dirty_col"
  elif (( _zline_git_cache_ahead > 0 )); then
    status_col="$ahead_col"
  fi

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_bg="${opts[--bg]:-${status_col}}"
    _zline_ret_fg="${opts[--fg]:-0}"
  else
    _zline_ret_fg="${opts[--color]:-${status_col}}"
    _zline_ret_bg="none"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="git:"
  else
    _zline_ret_icon=$'\uE0A0 '
  fi
}
