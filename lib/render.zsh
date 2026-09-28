typeset -g _zline_style="lean"
typeset -g _zline_mode="nerdfont"
typeset -g _zline_sep_left=""
typeset -g _zline_sep_right=""
typeset -g _zline_sep_left_soft=""
typeset -g _zline_sep_right_soft=""

typeset -ga _zline_compiled_left_names=()
typeset -ga _zline_compiled_left_args=()
typeset -ga _zline_compiled_right_names=()
typeset -ga _zline_compiled_right_args=()

typeset -gA _zline_registered_segments=(
  dir 1
  git 1
  status 1
  exec_time 1
  prompt_char 1
  venv 1
  k8s 1
  node 1
  time 1
  newline 1
)

_zline_visual_len() {
  local str="$1"
  local -i low=0 high=256 mid
  while (( low < high )); do
    (( mid = (low + high + 1) / 2 ))
    if [[ "${(%):-${str}%${mid}(l.1.0)}" == *1 ]]; then
      low=$mid
    else
      high=$(( mid - 1 ))
    fi
  done
  REPLY=$low
}

_zline_set_style_separators() {
  case "$_zline_style" in
    powerline|rainbow)
      if [[ "$_zline_mode" == "ascii" ]]; then
        _zline_sep_left=">"
        _zline_sep_right="<"
        _zline_sep_left_soft="|"
        _zline_sep_right_soft="|"
      else
        _zline_sep_left=$'\uE0B0'
        _zline_sep_right=$'\uE0B2'
        _zline_sep_left_soft=$'\uE0B1'
        _zline_sep_right_soft=$'\uE0B3'
      fi
      ;;
    *)
      _zline_sep_left=" "
      _zline_sep_right=" "
      _zline_sep_left_soft=" "
      _zline_sep_right_soft=" "
      ;;
  esac
}

_zline_compile_tokens() {
  local side="$1"
  shift
  local -a items=("$@")
  local -a names=()
  local -a args=()
  local cur_name=""
  local cur_args=""
  local item

  for item in "${items[@]}"; do
    if [[ "$item" == *" "* ]]; then
      if [[ -n "$cur_name" ]]; then
        names+=("$cur_name")
        args+=("${cur_args# }")
        cur_name=""
        cur_args=""
      fi
      local s_name="${item%% *}"
      local s_arg="${item#* }"
      names+=("$s_name")
      args+=("$s_arg")
      continue
    fi

    if [[ -n "${_zline_registered_segments[$item]}" || $+functions[zline_segment_${item}] == 1 ]]; then
      if [[ -n "$cur_name" ]]; then
        names+=("$cur_name")
        args+=("${cur_args# }")
        cur_args=""
      fi
      cur_name="$item"
    else
      cur_args+=" $item"
    fi
  done

  if [[ -n "$cur_name" ]]; then
    names+=("$cur_name")
    args+=("${cur_args# }")
  fi

  if [[ "$side" == "left" ]]; then
    _zline_compiled_left_names=("${names[@]}")
    _zline_compiled_left_args=("${args[@]}")
  else
    _zline_compiled_right_names=("${names[@]}")
    _zline_compiled_right_args=("${args[@]}")
  fi
}

zline_compile() {
  _zline_set_style_separators
  _zline_compile_tokens "left" "${zline_left[@]}"
  _zline_compile_tokens "right" "${zline_right[@]}"
}

_zline_render_left_segment_lean() {
  local icon="$1"
  local content="$2"
  local fg="$3"

  local fg_code=""
  if [[ -n "$fg" ]]; then
    _zline_fg "$fg"
    fg_code="$REPLY"
  fi

  REPLY=""
  if [[ -n "$icon" ]]; then
    REPLY+="${fg_code}${icon}%f"
    [[ -n "$content" ]] && REPLY+=" "
  fi
  if [[ -n "$content" ]]; then
    REPLY+="${fg_code}${content}%f"
  fi
}

_zline_render_left_segment_powerline() {
  local icon="$1"
  local content="$2"
  local fg="$3"
  local bg="$4"
  local last_bg="$5"

  local out=""
  local fg_code=""
  local bg_code=""
  _zline_fg "${fg:-7}"
  fg_code="$REPLY"
  _zline_bg "${bg:-0}"
  bg_code="$REPLY"

  if [[ "$last_bg" != "none" ]]; then
    local sep_fg=""
    local sep_bg=""
    _zline_fg "$last_bg"
    sep_fg="$REPLY"
    _zline_bg "$bg"
    sep_bg="$REPLY"
    out+="${sep_bg}${sep_fg}${_zline_sep_left}%f"
  fi

  out+="${bg_code}${fg_code} "
  [[ -n "$icon" ]] && out+="${icon} "
  out+="${content} %f"
  REPLY="$out"
}

_zline_render_left() {
  local out=""
  local last_bg="none"
  local count=${#_zline_compiled_left_names}
  local -i i

  for (( i = 1; i <= count; i++ )); do
    local name="${_zline_compiled_left_names[i]}"
    local raw_args="${_zline_compiled_left_args[i]}"

    if [[ "$name" == "newline" ]]; then
      if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
        if [[ "$last_bg" != "none" ]]; then
          local end_fg=""
          _zline_fg "$last_bg"
          end_fg="$REPLY"
          out+="%k${end_fg}${_zline_sep_left}%f"
          last_bg="none"
        fi
      fi
      out+=$'\n'
      continue
    fi

    typeset -g _zline_ret_content=""
    typeset -g _zline_ret_fg=""
    typeset -g _zline_ret_bg=""
    typeset -g _zline_ret_icon=""

    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" ${(z)raw_args}
    fi

    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      local seg_bg="${_zline_ret_bg:-0}"
      _zline_render_left_segment_powerline "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg" "$seg_bg" "$last_bg"
      out+="$REPLY"
      last_bg="$seg_bg"
    else
      _zline_render_left_segment_lean "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg"
      [[ -n "$out" && "$out" != *$'\n' ]] && out+=" "
      out+="$REPLY"
    fi
  done

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    if [[ "$last_bg" != "none" ]]; then
      local end_fg=""
      _zline_fg "$last_bg"
      end_fg="$REPLY"
      out+="%k${end_fg}${_zline_sep_left}%f "
    fi
  else
    [[ -n "$out" && "$out" != *$'\n' && "$out" != *" " ]] && out+=" "
  fi

  REPLY="$out"
}

_zline_render_right_segment_powerline() {
  local icon="$1"
  local content="$2"
  local fg="$3"
  local bg="$4"
  local last_bg="$5"

  local out=""
  local fg_code=""
  local bg_code=""
  local sep_fg=""
  local sep_bg=""
  _zline_fg "${fg:-7}"
  fg_code="$REPLY"
  _zline_bg "${bg:-0}"
  bg_code="$REPLY"

  _zline_fg "$bg"
  sep_fg="$REPLY"
  if [[ "$last_bg" == "none" ]]; then
    sep_bg="%k"
  else
    _zline_bg "$last_bg"
    sep_bg="$REPLY"
  fi

  out+="${sep_bg}${sep_fg}${_zline_sep_right}%f"
  out+="${bg_code}${fg_code} "
  [[ -n "$icon" ]] && out+="${icon} "
  out+="${content} %f"
  REPLY="$out"
}

_zline_render_right() {
  local out=""
  local last_bg="none"
  local count=${#_zline_compiled_right_names}
  local -i i

  for (( i = 1; i <= count; i++ )); do
    local name="${_zline_compiled_right_names[i]}"
    local raw_args="${_zline_compiled_right_args[i]}"

    typeset -g _zline_ret_content=""
    typeset -g _zline_ret_fg=""
    typeset -g _zline_ret_bg=""
    typeset -g _zline_ret_icon=""

    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" ${(z)raw_args}
    fi

    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      local seg_bg="${_zline_ret_bg:-0}"
      _zline_render_right_segment_powerline "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg" "$seg_bg" "$last_bg"
      out+="$REPLY"
      last_bg="$seg_bg"
    else
      _zline_render_left_segment_lean "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg"
      [[ -n "$out" ]] && out+=" "
      out+="$REPLY"
    fi
  done

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    [[ -n "$out" ]] && out+="%k"
  fi

  REPLY="$out"
}

zline_render() {
  zline_hook run pre_render
  _zline_render_left
  PROMPT="$REPLY"
  _zline_render_right
  RPROMPT="$REPLY"
  zline_hook run post_render
}
