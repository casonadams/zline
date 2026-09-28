typeset -g _zline_git_cache_branch=""
typeset -gi _zline_git_cache_staged=0
typeset -gi _zline_git_cache_unstaged=0
typeset -gi _zline_git_cache_untracked=0
typeset -gi _zline_git_cache_ahead=0
typeset -gi _zline_git_cache_behind=0
typeset -gi _zline_git_cache_conflicts=0
typeset -gi _zline_git_cache_valid=0

_zline_git_read_head() {
  emulate -L zsh
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

_zline_git_read_stash() {
  emulate -L zsh
  local dir="$1"
  local stash_file="${dir}/.git/logs/refs/stash"
  local -i count=0
  if [[ -f "$stash_file" ]]; then
    local line
    while IFS= read -r line; do
      (( count += 1 ))
    done < "$stash_file" 2>/dev/null
  fi
  REPLY=$count
}

_zline_git_format_details() {
  emulate -L zsh
  local ahead_sym="$1"
  local behind_sym="$2"
  local -i stash_cnt="${3:-0}"
  local stash_sym="$4"
  local staged_icon="${5:-+}"
  local unstaged_icon="${6:-!}"
  local untracked_icon="${7:-?}"
  local conflict_icon="${8:-x}"

  local -a items=()
  (( _zline_git_cache_conflicts > 0 )) && items+=("${conflict_icon}${_zline_git_cache_conflicts}")
  (( _zline_git_cache_staged > 0 )) && items+=("${staged_icon}${_zline_git_cache_staged}")
  (( _zline_git_cache_unstaged > 0 )) && items+=("${unstaged_icon}${_zline_git_cache_unstaged}")
  (( _zline_git_cache_untracked > 0 )) && items+=("${untracked_icon}${_zline_git_cache_untracked}")

  local a_sym="${ahead_sym}"
  local b_sym="${behind_sym}"

  if [[ -z "$a_sym" ]]; then
    if [[ "$_zline_mode" == "ascii" ]]; then
      a_sym="^"
    else
      a_sym=$'\u21E1'
    fi
  fi

  if [[ -z "$b_sym" ]]; then
    if [[ "$_zline_mode" == "ascii" ]]; then
      b_sym="v"
    else
      b_sym=$'\u21E3'
    fi
  fi

  (( _zline_git_cache_ahead > 0 )) && items+=("${a_sym}${_zline_git_cache_ahead}")
  (( _zline_git_cache_behind > 0 )) && items+=("${b_sym}${_zline_git_cache_behind}")

  if (( stash_cnt > 0 )); then
    local s_sym="${stash_sym}"
    if [[ -z "$s_sym" ]]; then
      if [[ "$_zline_mode" == "ascii" ]]; then
        s_sym="*"
      else
        s_sym=$'\u2691'
      fi
    fi
    items+=("${s_sym}${stash_cnt}")
  fi

  REPLY="${(j: :)items}"
}

zline_segment_git() {
  emulate -L zsh
  local -A opts=()
  local -a flags=()
  zparseopts -E -D -A opts -K \
    -ignore-submodules=flags -submodule=flags \
    -clean:=opts -dirty:=opts -ahead:=opts -color:=opts \
    -staged-icon:=opts -unstaged-icon:=opts -untracked-icon:=opts -conflict-icon:=opts \
    -ahead-icon:=opts -behind-icon:=opts -stash-icon:=opts \
    -ahead-sym:=opts -behind-sym:=opts -stash-sym:=opts \
    -fg:=opts -bg:=opts -icon:=opts

  _zline_find_git_root "$PWD" || true
  local git_root="$REPLY"
  if [[ -z "$git_root" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_git_read_head "$git_root"
  local branch="$REPLY"
  [[ -z "$branch" ]] && { _zline_ret_content=""; return 0; }

  if (( ${flags[(Ie)--submodule]} > 0 )) && [[ -f "${git_root}/.git" ]]; then
    if [[ "$_zline_mode" == "ascii" ]]; then
      branch="${branch} [sub]"
    else
      branch="${branch} "$'\uF04F9'
    fi
  fi

  _zline_worker_send "git" "$git_root" 2>/dev/null || true

  local details=""
  local -i is_dirty=0
  _zline_git_read_stash "$git_root"
  local -i stash_count=$REPLY

  if (( _zline_git_cache_valid == 1 || stash_count > 0 )); then
    local staged_ic="${opts[--staged-icon]:-+}"
    local unstaged_ic="${opts[--unstaged-icon]:-!}"
    local untracked_ic="${opts[--untracked-icon]:-?}"
    local conflict_ic="${opts[--conflict-icon]:-x}"
    local ahead_ic="${opts[--ahead-icon]:-${opts[--ahead-sym]}}"
    local behind_ic="${opts[--behind-icon]:-${opts[--behind-sym]}}"
    local stash_ic="${opts[--stash-icon]:-${opts[--stash-sym]}}"

    _zline_git_format_details "$ahead_ic" "$behind_ic" "$stash_count" "$stash_ic" \
      "$staged_ic" "$unstaged_ic" "$untracked_ic" "$conflict_ic"
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
